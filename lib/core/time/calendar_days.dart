/// La fecha (y/m/d) de [value], sin hora.
DateTime calendarDate(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// [days] días de calendario después de [base], insensible a DST.
DateTime addDays(DateTime base, int days) =>
    DateTime(base.year, base.month, base.day + days);

/// Días de calendario entre dos fechas, insensible a DST.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
