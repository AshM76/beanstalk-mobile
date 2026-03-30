class WeeklyPendingForm {
  WeeklyPendingForm({
    this.weeklyId,
    this.formId,
    this.formAssignedDate,
  });

  String? weeklyId;
  String? formId;
  DateTime? formAssignedDate;

  factory WeeklyPendingForm.fromJson(Map<String, dynamic> parsedJson) {
    return new WeeklyPendingForm(
      weeklyId: parsedJson['weekly_id'] ?? "",
      formId: parsedJson['form_id'] ?? "",
      formAssignedDate: parsedJson['form_assigned_date'] is Map
          ? DateTime.parse(parsedJson['form_assigned_date']['value'])
          : DateTime.parse(parsedJson['form_assigned_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "weekly_id": this.weeklyId,
      "form_id": this.formId,
      "form_assigned_date": this.formAssignedDate,
    };
  }
}
