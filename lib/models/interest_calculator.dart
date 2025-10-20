import 'dart:math';

class InterestCalculator {
  double calculate(
      String calculationType,
      double principal,
      double rate,
      double time,
      double futureValue,
      double interest,
      int compoundingPeriods,
      double timeCompounding) {
    switch (calculationType) {
      case 'Interés Simple - Monto Futuro':
        return calculateSimpleInterestFutureValue(principal, rate, time);
      case 'Interés Simple - Tasa de Interés':
        return calculateSimpleInterestRate(futureValue, principal, time);
      case 'Interés Simple - Tiempo':
        return calculateSimpleInterestTime(futureValue, principal, rate);
      case 'Interés Simple - Capital Inicial':
        return calculateSimpleInterestPrincipal(interest, rate, time);
      case 'Interés Compuesto - Monto Futuro':
        return calculateCompoundInterestFutureValue(
            principal, rate, timeCompounding, compoundingPeriods);
      case 'Interés Compuesto - Tasa de Interés':
        return calculateCompoundInterestRate(
            futureValue, principal, timeCompounding, compoundingPeriods);
      case 'Interés Compuesto - Tiempo':
        return calculateCompoundInterestTime(
            futureValue, principal, rate, compoundingPeriods);
      case 'Interés Compuesto - Capital Inicial':
        return calculateCompoundInterestPrincipal(futureValue,
            rate / compoundingPeriods, timeCompounding * compoundingPeriods);
      case 'Anualidad Ordinaria - Valor Futuro':
        return calculateFutureValueOrdinaryAnnuity(principal, rate, time);
      case 'Anualidad Ordinaria - Valor Presente':
        return calculatePresentValueOrdinaryAnnuity(principal, rate, time);
      case 'Anualidad Anticipada - Valor Futuro':
        return calculateFutureValueAnnuityDue(principal, rate, time);
      case 'Anualidad Anticipada - Valor Presente':
        return calculatePresentValueAnnuityDue(principal, rate, time);
      default:
        return 0;
    }
  }

  double convertTimeToYears(double days, double months, double years) {
    return years + (months / 12) + (days / 360);
  }

  String formatTime(double timeInYears) {
    int years = timeInYears.floor();
    double fractionalYear = timeInYears - years;
    int days = (fractionalYear * 360).round();
    int months = (days / 30).floor();
    days = days % 30;
    return "$years años, $months meses, $days días";
  }

  // Cálculos de interés simple
  double calculateSimpleInterestFutureValue(
      double principal, double rate, double time) {
    return principal * (1 + rate * time / 100);
  }

  double calculateSimpleInterestRate(
      double futureValue, double principal, double time) {
    return (futureValue / principal - 1) / time * 100;
  }

  double calculateSimpleInterestTime(
      double futureValue, double principal, double rate) {
    return (futureValue / principal - 1) / rate * 100;
  }

  double calculateSimpleInterestPrincipal(
      double interest, double rate, double time) {
    return interest / (rate * time / 100);
  }

  // Cálculos de interés compuesto
  double calculateCompoundInterestFutureValue(
      double principal, double rate, double time, int compoundingPeriods) {
    double ratePerPeriod = rate / compoundingPeriods;
    double totalPeriods = time * compoundingPeriods;
    return principal * pow((1 + ratePerPeriod / 100), totalPeriods);
  }

  double calculateCompoundInterestRate(double futureValue, double principal,
      double time, int compoundingPeriods) {
    double totalPeriods = time * compoundingPeriods;
    return (pow((futureValue / principal), (1 / totalPeriods)) - 1) *
        compoundingPeriods *
        100;
  }

  double calculateCompoundInterestTime(double futureValue, double principal,
      double rate, int compoundingPeriods) {
    double ratePerPeriod = rate / compoundingPeriods;
    return log(futureValue / principal) /
        (compoundingPeriods * log(1 + ratePerPeriod / 100));
  }

  double calculateCompoundInterestPrincipal(
      double futureValue, double rate, double periods) {
    double ratePerPeriod = rate / 100;
    return futureValue / pow((1 + ratePerPeriod), periods);
  }

  // Cálculos de anualidades
  double calculateFutureValueOrdinaryAnnuity(
      double payment, double rate, double time) {
    double ratePerPeriod = rate / 100;
    return payment * ((pow(1 + ratePerPeriod, time) - 1) / ratePerPeriod);
  }

  double calculatePresentValueOrdinaryAnnuity(
      double payment, double rate, double time) {
    double ratePerPeriod = rate / 100;
    return payment * ((1 - pow(1 + ratePerPeriod, -time)) / ratePerPeriod);
  }

  double calculateFutureValueAnnuityDue(
      double payment, double rate, double time) {
    double ratePerPeriod = rate / 100;
    return payment *
        ((pow(1 + ratePerPeriod, time) - 1) / ratePerPeriod) *
        (1 + ratePerPeriod);
  }

  double calculatePresentValueAnnuityDue(
      double payment, double rate, double time) {
    double ratePerPeriod = rate / 100;
    return payment *
        ((1 - pow(1 + ratePerPeriod, -time)) / ratePerPeriod) *
        (1 + ratePerPeriod);
  }

  // Cálculo de tasa de interés económica
  double calculateInterestRate(double principal, double rate, double time) {
    return principal * (1 + rate * time / 100);
  }
}
