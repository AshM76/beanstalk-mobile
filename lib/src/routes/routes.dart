import 'package:flutter/material.dart';

// Onboarding & auth
import 'package:beanstalk_mobile/src/pages/onboarding/signin_page.dart';
import 'package:beanstalk_mobile/src/pages/onboarding/signup_page.dart';
import 'package:beanstalk_mobile/src/pages/onboarding/forgotpassword/forgotPassword_page.dart';
import 'package:beanstalk_mobile/src/pages/onboarding/forgotpassword/updatePassword_page.dart';
import 'package:beanstalk_mobile/src/pages/onboarding/forgotpassword/validateCode_page.dart';
import 'package:beanstalk_mobile/src/pages/onboarding/onboarding_agree_page.dart';
import 'package:beanstalk_mobile/src/pages/onboarding/onboarding_profile_page.dart';
import 'package:beanstalk_mobile/src/pages/onboarding/onboarding_location_page.dart';
import 'package:beanstalk_mobile/src/pages/onboarding/onboarding_conditions_page.dart';
import 'package:beanstalk_mobile/src/pages/onboarding/onboarding_question_page.dart';
import 'package:beanstalk_mobile/src/pages/onboarding/onboarding_resume_page.dart';

// Core navigation & dashboard
import 'package:beanstalk_mobile/src/pages/navigation/navigation_page.dart';
import 'package:beanstalk_mobile/src/pages/dashboard/dashboard_page.dart';
import 'package:beanstalk_mobile/src/pages/profile/profile_page.dart';

// Lessons (replaces sessions)
import 'package:beanstalk_mobile/src/pages/lessons/session_setup_page.dart';
import 'package:beanstalk_mobile/src/pages/lessons/session_start_page.dart';
import 'package:beanstalk_mobile/src/pages/lessons/session_active_page.dart';
import 'package:beanstalk_mobile/src/pages/lessons/session_resume_page.dart';

// Progress & history
import 'package:beanstalk_mobile/src/pages/history/history_page.dart';

// Chat / mentors
import 'package:beanstalk_mobile/src/pages/chatting/chat_list_page.dart';
import 'package:beanstalk_mobile/src/pages/chatting/chat_private_page.dart';
import 'package:beanstalk_mobile/src/pages/chatting/chat_clinician_private_page.dart';

// Rewards (replaces deals)
import 'package:beanstalk_mobile/src/pages/rewards/deals_detail_page.dart';

// Courses & mentors (replaces dispensary/clinicians)
import 'package:beanstalk_mobile/src/pages/courses/dispensary_detail_page.dart';
import 'package:beanstalk_mobile/src/pages/mentors/clinicians_detail_page.dart';

// Quizzes (replaces weekly forms)
import 'package:beanstalk_mobile/src/pages/quizzes/weekly_form_page.dart';

Map<String, WidgetBuilder> applicationRoutes() {
  return <String, WidgetBuilder>{
    // ── Auth ──────────────────────────────────────────────────
    'signin':           (ctx) => SignInPage(),
    'signup':           (ctx) => SignUpPage(),
    'forgot_password':  (ctx) => ForgotPasswordPage(),
    'validate_code':    (ctx) => ValidateCodePage(),
    'update_password':  (ctx) => UpdatePasswordPage(),

    // ── Onboarding ────────────────────────────────────────────
    'onboarding_agree':    (ctx) => OnboardingAgreePage(),
    'onboarding_profile':  (ctx) => OnboardingProfilePage(),
    'onboarding_location': (ctx) => OnboardingLocationPage(),
    'onboarding_topic':    (ctx) => OnboardingConditionPage(),    // topic selection
    'onboarding_question': (ctx) => OnboardingQuestionPage(),
    'onboarding_resume':   (ctx) => OnboardingResumePage(),

    // ── Main app ──────────────────────────────────────────────
    'navigation':  (ctx) => NavigationApp(),
    'dashboard':   (ctx) => DashboardPage(),
    'profile':     (ctx) => ProfilePage(),

    // ── Lessons ───────────────────────────────────────────────
    'lesson_setup':   (ctx) => SessionSetupPage(),
    'lesson_start':   (ctx) => SessionStartPage(),
    'lesson_active':  (ctx) => SessionActivePage(),
    'lesson_resume':  (ctx) => SessionResumePage(),

    // ── Progress ──────────────────────────────────────────────
    'history':  (ctx) => HistoryPage(),

    // ── Courses ───────────────────────────────────────────────
    'course_detail':  (ctx) => DispensarieDetailPage(),

    // ── Mentors ───────────────────────────────────────────────
    'mentor_detail':           (ctx) => ClinicianDetailPage(),
    'chat_list':               (ctx) => ChatListPage(),
    'chat_private':            (ctx) => ChatPrivatePage(),
    'chat_mentor_private':     (ctx) => ChatClinicianPrivatePage(),

    // ── Rewards ───────────────────────────────────────────────
    'reward_detail':  (ctx) => DealsDetailPage(),

    // ── Quizzes ───────────────────────────────────────────────
    'quiz': (ctx) => WeeklyFormPage(),
  };
}
