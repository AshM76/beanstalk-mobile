# Plan: Age-Verified User Groups & Contest System for Beanstalk

## Context
Currently, Beanstalk collects user age but doesn't verify it rigorously. The new requirement is to:
1. Accurately verify and confirm user age
2. Segment users into age groups (middle school, high school, college, adults)
3. Run virtual portfolio trading contests within age-matched cohorts
4. Ensure proper consent/EULA for different user types and ages
5. Capture and organize demographic data

This requires significant extensions to:
- User model (age groups, demographics, consent tracking)
- Authentication flow (age verification, parental consent for minors)
- EULA/Consent management system
- Web portal user types and permissions
- Contest and portfolio infrastructure (future module)

## High-Level Architecture

### 1. EXTENDED USER MODEL
**File:** `/Users/mehtafam/Downloads/api/src/GoogleCloudPlatform/Models/user/user.model.js`

Add new fields to BigQuery schema:
```
// Age & Verification (replace current user_age with proper DOB + segments)
- user_dateOfBirth: DATE (REQUIRED) - actual date of birth
- user_age_verified: BOOLEAN (default false) - has passed age verification
- user_age_verification_method: ENUM (self_reported|plaid|id_verification|parental_consent)
- user_age_verification_timestamp: DATETIME - when verified
- user_age_group: ENUM (middle_school|high_school|college|adults) - calculated from DOB
- user_age_group_updated_at: DATETIME

// Demographics
- user_gender: STRING (existing, keep)
- user_city: STRING - new
- user_state: STRING - new
- user_country: STRING - new
- user_education_level: ENUM (middle_school|high_school|some_college|college|graduate|other) - new
- user_income_bracket: ENUM (under_25k|25k_50k|50k_100k|100k_250k|250k_plus|prefer_not_to_say) - new
- user_primary_interest: STRING (trading|investing|learning|competing|other) - new
- user_risk_tolerance: ENUM (conservative|moderate|aggressive) - new

// Parental Consent (for under 18)
- user_parent_name: STRING (if under 18) - new
- user_parent_email: STRING (if under 18) - new
- user_parent_consent: BOOLEAN (if under 18) - new
- user_parent_consent_timestamp: DATETIME - new
- user_parent_email_verified: BOOLEAN - new
- user_parent_verification_token: STRING - temporary token for parent verification
- user_parent_verification_token_expires: DATETIME

// EULA & Consent Tracking (replace simple boolean)
- user_consents: RECORD (REPEATED) - array of consent records, new
  - consent_id: STRING (uuid)
  - consent_type: ENUM (terms_of_service|privacy_policy|contest_rules|parental_consent|marketing)
  - consent_version: STRING (e.g., "1.0", "2.1")
  - consent_accepted: BOOLEAN
  - consent_accepted_at: DATETIME
  - consent_accepted_from_ip: STRING
  - consent_accepted_device_info: STRING (OS, app version, etc.)
  - user_type_at_consent: ENUM (consumer|dispensary_manager|contest_participant|admin)

// Contest Participation
- user_contest_eligible: BOOLEAN - new (age verified + consents signed)
- user_contest_opt_in: BOOLEAN - new (wants to participate in contests)
- user_virtual_portfolio_account_id: STRING - new (link to trading account)
- user_portfolio_decimal_places_precision: INTEGER (2 for USD) - new

// Account Status
- user_account_status: ENUM (pending_verification|active|suspended|banned) - replace validation status
- user_account_status_reason: STRING (enum or description)
- user_account_created_at: DATETIME (existing user_signupDate, rename)
- user_account_verified_at: DATETIME (new - when fully verified)
```

**Why these changes:**
- Proper DOB storage instead of treating age as DATE
- Age group calculation from DOB for contest matching
- Demographics for user profiling and contest pairing
- Parental consent workflow for minors
- Multi-consent tracking with versions (EULA, Privacy, Contest rules)
- Audit trail for regulatory compliance

---

### 2. EULA & CONSENT MANAGEMENT SYSTEM
**New File:** `/Users/mehtafam/Downloads/api/src/GoogleCloudPlatform/Models/compliance/eula.model.js`

Separate model for version-controlled documents:
```
// EULA/Consent Documents Table
eula_documents {
  eula_id: STRING (uuid)
  eula_type: ENUM (terms_of_service|privacy_policy|contest_rules)
  user_type_applicable: ENUM[] (consumer|dispensary_manager|all)
  age_group_applicable: ENUM[] (middle_school|high_school|college|adults|all)
  version: STRING (semantic versioning: "1.0.0")
  major_version: INTEGER
  minor_version: INTEGER
  patch_version: INTEGER
  content_html: STRING (full EULA content in HTML)
  content_plain_text: STRING (plain text version)
  effective_date: DATE (when this version goes live)
  superseded_date: DATE (null if current, date if older version)
  is_current_version: BOOLEAN
  requires_acceptance: BOOLEAN (true for ToS/Privacy, false for informational)
  created_at: DATETIME
  created_by_admin_id: STRING (which admin created)
  change_summary: STRING (what changed from previous version)
}

// User Consent Acceptance Log
user_consent_log {
  log_id: STRING (uuid)
  user_id: STRING (foreign key)
  eula_id: STRING (which document version)
  acceptance_timestamp: DATETIME
  acceptance_ip_address: STRING
  acceptance_device_fingerprint: STRING
  acceptance_user_agent: STRING
  acceptance_status: ENUM (accepted|declined|expired)
  notes: STRING (admin notes if declined)
  parent_verification_token_used: BOOLEAN (if parental consent)
}
```

**Purpose:** Version-controlled EULAs with audit trail for regulatory compliance.

---

### 3. AGE VERIFICATION SERVICE
**New File:** `/Users/mehtafam/Downloads/api/src/services/age_verification.service.js`

Three verification methods:
```
ageVerificationService {
  // Method 1: Self-reported (current approach, least reliable)
  verifySelfReported(dateOfBirth)
    → validate age >= 13
    → mark as 'self_reported'
    → set age_verified: true

  // Method 2: Third-party ID verification (ID.me, Socure, etc.)
  initIdVerification(userId)
    → generate unique session ID
    → return redirect URL to ID verification provider
    → handles webhook callback from provider

  completeIdVerification(userId, verificationResult)
    → validate result signature
    → store age_verification_method: 'id_verification'
    → set age_verified: true, age_group calculated

  // Method 3: Parental Consent (for under 18)
  initParentalConsent(userId, parentEmail, minorName)
    → generate parent_verification_token (JWT, 7-day expiry)
    → send email to parent with verification link
    → create pending consent record

  verifyParentConsent(token)
    → validate token signature/expiry
    → confirm parent identity (optional: email re-verification)
    → set parent_consent: true
    → set age_verified: true (minor account now active)
    → send confirmation to parent + minor

  // Helper: Calculate age group from DOB
  getAgeGroup(dateOfBirth) {
    const age = calculateAge(dateOfBirth);
    if (age < 13) return null; // Too young
    if (age < 15) return 'middle_school'; // 13-14
    if (age < 19) return 'high_school'; // 15-18
    if (age < 26) return 'college'; // 19-25
    return 'adults'; // 26+
  }
}
```

---

### 4. WEB PORTAL USER TYPES & PERMISSIONS
**Files to modify/extend:**
- `/Users/mehtafam/Downloads/web/src/app/core/account/account.types.ts`
- `/Users/mehtafam/Downloads/api/src/GoogleCloudPlatform/Models/roles/roles.model.js`

Add new user types with role-based permissions:

```typescript
// User Types
enum UserType {
  // Consumer users
  CONSUMER_REGULAR = 'consumer_regular',        // Regular user (13+)
  CONSUMER_MINOR = 'consumer_minor',            // Under 18, parental consent
  CONSUMER_CONTEST_PARTICIPANT = 'consumer_contest_participant', // Opt-in contest

  // Business users (existing, enhance)
  DISPENSARY_OWNER = 'dispensary_owner',        // Main account
  DISPENSARY_MANAGER = 'dispensary_manager',    // Staff account

  // Platform admin users (new)
  ADMIN_SUPER = 'admin_super',                  // Full platform access
  ADMIN_CONTEST_MANAGER = 'admin_contest_manager', // Create/manage contests
  ADMIN_MODERATOR = 'admin_moderator',          // Monitor users, detect fraud
  ADMIN_ANALYTICS = 'admin_analytics',          // Reporting/BI access
}

// Permission Matrix
const userPermissions = {
  [UserType.CONSUMER_REGULAR]: [
    'view_own_profile',
    'edit_own_profile',
    'view_dispensaries',
    'view_deals',
    'participate_in_contests',
    'access_virtual_portfolio',
    'chat_with_clinicians',
  ],

  [UserType.CONSUMER_MINOR]: [
    'view_own_profile',
    'view_dispensaries', // Read-only
    'participate_in_contests', // Age-matched contests only
    'access_virtual_portfolio', // Limited to educational mode
    // Cannot: edit payment info, communicate with strangers
  ],

  [UserType.DISPENSARY_OWNER]: [
    'view_own_dispensary',
    'edit_dispensary_info',
    'create_deals',
    'manage_deals',
    'view_sales_analytics',
    'manage_team_members',
    'view_revenue_reports',
  ],

  [UserType.ADMIN_CONTEST_MANAGER]: [
    'create_contests',
    'edit_contests',
    'set_contest_rules',
    'view_contest_leaderboards',
    'award_prizes',
    'view_contest_analytics',
  ],

  [UserType.ADMIN_MODERATOR]: [
    'view_all_users',
    'review_age_verification_disputes',
    'flag_suspicious_accounts',
    'review_fraud_reports',
    'suspend_accounts_temporarily',
    'view_user_activity_logs',
  ],

  [UserType.ADMIN_ANALYTICS]: [
    'view_platform_metrics',
    'export_user_data',
    'view_contest_performance',
    'generate_reports',
  ],

  [UserType.ADMIN_SUPER]: [
    '*', // All permissions
  ]
};
```

---

### 5. ENHANCED ONBOARDING FLOW
**Files to modify:**
- Mobile: `/Users/mehtafam/Downloads/mobile/lib/src/blocs/onboarding_bloc.dart`
- Web: `/Users/mehtafam/Downloads/web/src/app/modules/onboarding/`

**New Mobile Consumer Flow (10 steps):**
1. Welcome
2. Authentication (email/password)
3. Age Verification (choose method: self-report, ID verify, or parental consent)
4. → IF Age < 18: Parental Consent email step
5. → IF Age >= 13: Continue
6. Legal Agreements (ToS, Privacy Policy, Contest Rules if opted in)
7. Profile Information (name, gender)
8. Demographics (education level, location, interests, risk tolerance)
9. Medical Profile (conditions, medications - existing)
10. Completion & Review

**New Web Admin Onboarding (4 steps):**
1. Admin Account Registration (email, password)
2. Role Assignment (super admin creates initial role)
3. Permissions Review
4. Activation (2FA setup required)

---

### 6. API ENDPOINTS TO ADD/MODIFY
**File:** `/Users/mehtafam/Downloads/api/src/routes/onboarding.routes.ts` (or separate file)

Age & Verification Endpoints:
```
POST   /api/onboarding/age-verify/self-report
       Request: { session_id, date_of_birth }
       Response: { verified: bool, age_group, age_verified_at }
       Validation: Age >= 13, DOB format

POST   /api/onboarding/age-verify/id-verification/init
       Response: { verification_session_id, redirect_url }
       (Redirect to ID verification provider)

POST   /api/onboarding/age-verify/id-verification/callback
       (Webhook from ID verification provider)
       Response: { user_verified, age_group }

POST   /api/onboarding/parental-consent/init
       Request: { user_id, parent_email, minor_name }
       Response: { consent_pending_id, verification_token_sent_to: email }
       Side-effect: Send parent verification email

POST   /api/onboarding/parental-consent/verify
       Request: { verification_token }
       Response: { verified: bool, minor_account_activated }

// Consent/EULA endpoints
GET    /api/compliance/eula/:eula_type?/:version?
       Response: { eula_id, content_html, version, effective_date }

POST   /api/compliance/accept-eula
       Request: { user_id, eula_id }
       Response: { accepted: bool, acceptance_timestamp }
       Side-effect: Log consent in user_consent_log

GET    /api/compliance/user-consents/:user_id
       Response: { consents: [ { type, version, accepted_at } ] }

// User demographics
PUT    /api/user/demographics
       Request: { education_level, income_bracket, interests, risk_tolerance }
       Response: { demographics_updated_at }

// Admin: user verification status
GET    /api/admin/users/:user_id/verification-status
       Response: { age_verified, age_group, parent_consent_status, consents_signed }

PUT    /api/admin/users/:user_id/account-status
       Request: { status, reason }
       Response: { user_id, status, updated_at }

// Contest eligibility check
GET    /api/user/contest-eligibility
       Response: {
         eligible: bool,
         age_group,
         required_consents_pending: [],
         parent_consent_pending: bool
       }
```

---

### 7. DATABASE MIGRATIONS
**New files to create:**
- `/Users/mehtafam/Downloads/api/migrations/001_add_age_verification.sql`
- `/Users/mehtafam/Downloads/api/migrations/002_add_demographics.sql`
- `/Users/mehtafam/Downloads/api/migrations/003_add_parental_consent.sql`
- `/Users/mehtafam/Downloads/api/migrations/004_add_eula_tracking.sql`

BigQuery schema changes (CREATE TABLE statements for new tables, ALTER TABLE for user_profile additions).

---

### 8. MIDDLEWARE & VALIDATION
**File:** `/Users/mehtafam/Downloads/api/src/middleware/age_verification.middleware.ts` (new)

```
// Middleware: Check age verification for contest routes
requireAgeVerified() {
  return (req, res, next) => {
    if (!req.user.age_verified) {
      return res.status(403).json({
        error: 'AGE_NOT_VERIFIED',
        message: 'Must complete age verification',
        next_step: '/onboarding/age-verify'
      });
    }
    next();
  };
}

// Middleware: Check age-appropriate content
requireAgeGroup(allowedGroups) {
  return (req, res, next) => {
    if (!allowedGroups.includes(req.user.age_group)) {
      return res.status(403).json({
        error: 'AGE_GROUP_NOT_ELIGIBLE',
        message: `This contest is for ${allowedGroups.join(', ')} users only`
      });
    }
    next();
  };
}

// Middleware: Check all consents signed
requireConsents(consentTypes) {
  return (req, res, next) => {
    const missingSome = consentTypes.filter(type =>
      !req.user.consents.find(c => c.consent_type === type && c.accepted)
    );
    if (missingSome.length > 0) {
      return res.status(403).json({
        error: 'CONSENTS_REQUIRED',
        missing_consents: missingSome
      });
    }
    next();
  };
}

// Middleware: Minor-specific restrictions
restrictIfMinor() {
  return (req, res, next) => {
    if (req.user.age_group === 'middle_school' || req.user.age_group === 'high_school') {
      if (!req.user.parent_email_verified) {
        return res.status(403).json({
          error: 'PARENTAL_CONSENT_REQUIRED'
        });
      }
    }
    next();
  };
}
```

---

## Implementation Phases

### Phase 1: Data Model & Backend (Weeks 1-2)
1. Extend user schema with new fields (age verification, demographics, consents)
2. Create EULA/compliance management tables
3. Implement age verification service (all 3 methods)
4. Create parental consent workflow
5. Implement EULA/consent tracking logic
6. Add validation middleware
7. Create database migrations

### Phase 2: API Endpoints (Week 2-3)
1. Implement onboarding endpoints for age verification
2. Implement parental consent endpoints
3. Implement EULA/consent endpoints
4. Implement user permission/role system enhancements
5. Add admin endpoints for verification status
6. Test all endpoints with postman/curl

### Phase 3: Mobile Onboarding (Week 3-4)
1. Update Flutter onboarding bloc with new 10-step flow
2. Add age verification UI (self-report, ID redirect, parental consent)
3. Add demographics form
4. Add EULA display & acceptance UI
5. Add parental consent verification page
6. Integration test with backend

### Phase 4: Web Portal Admin (Week 4-5)
1. Create admin user types and permission matrix
2. Build admin dashboard for user verification
3. Build EULA management interface (create/version documents)
4. Build contest management interface (basic)
5. Build analytics dashboard
6. Implement permission-based UI routing

### Phase 5: Contest & Portfolio Foundation (Week 5-6)
1. Create contest model/schema (scope for future phase)
2. Add contest eligibility checks
3. Create virtual portfolio account linking
4. Test end-to-end: signup → age verify → eligibility check
5. Deploy to staging

---

## Critical Files to Modify/Create

### Backend (Node.js)
| File | Action | Purpose |
|------|--------|---------|
| `/api/src/GoogleCloudPlatform/Models/user/user.model.js` | MODIFY | Add age verification, demographics, parental consent, consent tracking fields |
| `/api/src/GoogleCloudPlatform/Models/compliance/eula.model.js` | CREATE | EULA versioning and management |
| `/api/src/GoogleCloudPlatform/Models/compliance/consent_log.model.js` | CREATE | Track all consent acceptances |
| `/api/src/services/age_verification.service.js` | CREATE | Age verification logic (3 methods) |
| `/api/src/services/parental_consent.service.js` | CREATE | Parental consent workflow |
| `/api/src/services/eula.service.js` | CREATE | EULA management and version control |
| `/api/src/middleware/age_verification.middleware.js` | CREATE | Permission/eligibility checking middleware |
| `/api/src/routes/compliance.routes.js` | CREATE | EULA/consent endpoints |
| `/api/src/controllers/compliance/eula.controller.js` | CREATE | EULA endpoint logic |
| `/api/src/controllers/age_verification.controller.js` | CREATE | Age verification endpoint logic |

### Mobile (Flutter)
| File | Action | Purpose |
|------|--------|---------|
| `/mobile/lib/src/models/user_profile_model.dart` | MODIFY | Add age_group, demographics, consent tracking |
| `/mobile/lib/src/blocs/onboarding_bloc.dart` | MODIFY | Extend to 10-step flow with age verification |
| `/mobile/lib/src/pages/onboarding/age_verification_page.dart` | CREATE | Age verification step |
| `/mobile/lib/src/pages/onboarding/parental_consent_page.dart` | CREATE | Parental consent UI |
| `/mobile/lib/src/pages/onboarding/demographics_page.dart` | CREATE | Demographics form |
| `/mobile/lib/src/pages/onboarding/eula_display_page.dart` | CREATE | EULA display & acceptance |
| `/mobile/lib/src/services/age_verification_service.dart` | CREATE | Client-side age verification logic |

### Web Portal (Angular)
| File | Action | Purpose |
|------|--------|---------|
| `/web/src/app/core/account/account.types.ts` | MODIFY | Add admin user types |
| `/web/src/app/core/auth/permissions.service.ts` | CREATE | Permission checking service |
| `/web/src/app/modules/admin/admin.module.ts` | CREATE | Admin module |
| `/web/src/app/modules/admin/user-verification/user-verification.component.ts` | CREATE | User verification dashboard |
| `/web/src/app/modules/admin/eula-management/eula-management.component.ts` | CREATE | EULA versioning UI |
| `/web/src/app/modules/admin/contest-manager/contest-manager.component.ts` | CREATE | Contest management interface |

---

## Validation Rules

**Age Verification:**
- DOB must be valid date in format YYYY-MM-DD
- Age must be >= 13
- Age must be <= 120
- Age < 18 requires parental consent (email verification)
- ID verification method: defer to third-party provider validation

**Parental Consent:**
- Parent email must be valid
- Verification token: 7-day expiry
- Parent can decline consent (minor account gets suspended)
- Parental consent required for: contests, certain features

**EULA/Consent:**
- Each user must accept current version of ToS before using platform
- Privacy policy acceptance required
- Contest Rules acceptance required IF participating in contests
- Minor-specific "Parental Consent" document if under 18
- All acceptances logged with timestamp, IP, device info

---

## Testing & Verification

### E2E Test Scenarios
1. **Adult signup with self-reported age:**
   - Sign up → Enter DOB (age 30) → Accept ToS/Privacy → Proceed
   - Verify: age_group = 'adults', age_verified = true

2. **Minor signup with parental consent:**
   - Sign up → Enter DOB (age 15) → System detects minor → Collect parent email
   - Parent receives email → Clicks verification link → Confirms consent
   - Verify: parent_email_verified = true, user account activated

3. **ID verification flow:**
   - Sign up → Choose ID verification → Redirect to ID.me → Complete ID scan
   - System receives verification callback → User age verified
   - Verify: age_verified = true, age_verification_method = 'id_verification'

4. **EULA versioning:**
   - Admin creates EULA v1.0 → Users sign
   - Admin releases EULA v1.1 → System marks old consents incomplete
   - Users see "Please accept updated Terms" → Sign new version
   - Verify: consent_version tracked, changelog recorded

5. **Contest eligibility:**
   - User completes onboarding → age_verified = true
   - User has age_group = 'high_school'
   - Contest manager creates "High School Trading Challenge"
   - User appears in eligible leaderboard
   - Another user (age_group = 'college') cannot see this contest

---

## Dependencies & Integrations

**Third-party Services:**
- ID Verification: ID.me, Socure, or equivalent (future choice)
- Email Service: SendGrid/AWS SES for parent consent emails
- Redis: Cache EULA versions, temporary verification tokens

**Existing Integrations (reuse):**
- BigQuery: User profile storage (extend existing schema)
- Auth middleware: Existing JWT/session validation
- Email system: Existing SendGrid setup for notifications

---

## Notes & Considerations

1. **Regulatory Compliance:** This system should comply with COPPA (Children's Online Privacy Protection Act) for users under 13, and general guardianship laws for 13-17 year-olds. Parental consent is legally required.

2. **Age Group Matching:** For contests, recommend matching by age_group + risk_tolerance to create fair competitive environments.

3. **Portfolio Integration:** Virtual portfolio account linking (user_virtual_portfolio_account_id) sets up for Phase 2 when Alpaca trading system is connected.

4. **Consent Versioning:** When EULAs update, users should be notified and required to re-accept. Track all versions in user_consents with timestamps.

5. **Privacy:** Parental email and consent data should be handled with care. Consider separate encrypted table/backup.

6. **Future Enhancement:** Implement single sign-on (OAuth2) for easier onboarding with existing accounts (Google, Apple, etc).

