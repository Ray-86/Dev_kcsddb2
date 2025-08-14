CREATE FUNCTION [kcsd].[get_PV]
(@InterestRate NUMERIC(18,10), --Rate is the interest rate per period.
@Nper          INT,           --Nper is the total number of payment
                              --periods in an annuity.
@Pmt           NUMERIC(18,10), --Pmt is the payment made each period;
                              --it cannot change over the life
                              --of the annuity.PaymentValue must be
                              --entered as a negative number.
@Fv            NUMERIC(18,10), --Fv is the future value, or the lump-sum
                              --amount that a series of future payments
                              --is worth right now. If Fv is omitted,
                              --it is assumed to be 0 (zero).
                              --FV must be entered as a negative number.
@Type          BIT            --Type is the number 0 or 1 and indicates
                              --when payments are due.
                              --If type is omitted, it is assumed to be 0
                              -- which represents at the end of the period.
                              --If payments are due at the beginning
                              --of the period, type should be 1.
)
RETURNS NUMERIC(18,2) --float
AS
  BEGIN
    DECLARE  @Value NUMERIC(18,2)
    SELECT @Value =
    Case WHEN @Type=0
    THEN @Pmt*(Power(Convert(float,(1 + @InterestRate)),@Nper)
    -1) /(((@InterestRate))
    * Power((Convert(float,1 + @InterestRate)),@Nper))
    + @Fv *
    Power(Convert(float,(1 + @InterestRate)),@Nper)
 
    WHEN @Type=1
    THEN @Pmt*(Power(Convert(float,(1 + @InterestRate / 100)),@Nper)
    -1) /(((@InterestRate / 100))
    * Power((Convert(float,1 + @InterestRate / 100)),@Nper))
    * (1 + @InterestRate / 100)
    + @Fv
    * Power(Convert(float,(1 + @InterestRate / 100)),@Nper)
    END
    RETURN @Value*-1

  END
