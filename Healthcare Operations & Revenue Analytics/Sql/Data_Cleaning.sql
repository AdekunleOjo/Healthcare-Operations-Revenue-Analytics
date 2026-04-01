
---Data Cleaning

-- Rename Excel-Imported Tables to Standard Names
EXEC sp_rename '[dbo].[Billing$]', 'Billing';
EXEC sp_rename '[dbo].[Medications$]', 'Medication';
EXEC sp_rename '[dbo].[Patients$]', 'Patients';
EXEC sp_rename '[dbo].[Visits$]', 'Visits';

-- Data Clening for Billing Table

-- Standardize IDs Across Tables (Billing, Patients, Visits)
-- Format: PREFIX000X
ALTER TABLE Billing
ADD CleanBillingID VARCHAR(10);

UPDATE Billing
SET CleanBillingID =
    'BILL' + RIGHT('0000' + 
        CAST(
            CAST(
                SUBSTRING(Billing_ID, PATINDEX('%[0-9]%', Billing_ID), LEN(Billing_ID))
            AS INT)
        AS VARCHAR), 4);

ALTER TABLE Billing
Drop column Billing_ID 

ALTER TABLE Billing
ADD PatientID VARCHAR(10);

UPDATE Billing
SET PatientID =
    'PAT' + RIGHT('0000' + 
        CAST(
            CAST(
                SUBSTRING(Patient_ID, PATINDEX('%[0-9]%', Patient_ID), LEN(Patient_ID))
            AS INT)
        AS VARCHAR), 4);
   
ALTER TABLE Billing
ADD VisitID VARCHAR(10);

UPDATE Billing
SET VisitID =
    'VIS' + RIGHT('0000' + 
        CAST(
            CAST(
                SUBSTRING(Visit_ID, PATINDEX('%[0-9]%', Visit_ID), LEN(Visit_ID))
            AS INT)
        AS VARCHAR), 4);

ALTER TABLE Billing
Drop column Patient_ID, Visit_ID

-- Clean and normalize mixed date formats to ISO standard (YYYY-MM-DD)
ALTER TABLE Billing
ADD CleanBilling_Date VARCHAR(10);

UPDATE Billing
SET CleanBilling_Date =
    CONVERT(
        varchar(10),
        COALESCE(
            TRY_CONVERT(date, Billing_Date, 101),
            TRY_CONVERT(date, Billing_Date, 103),
            TRY_CONVERT(date, Billing_Date, 111)
        ),
        23
    );

ALTER TABLE Billing
Drop column Billing_Date

EXEC sp_rename 'Billing.CleanBilling_Date', 'Billing_Date', 'COLUMN';

-- Data cleaning: standardize Total_Amount by removing negatives
UPDATE Billing
SET Total_Amount = ABS(Total_Amount);

-- Standardize Payment_Status Values (Case & Format Normalization)
UPDATE Billing
SET Payment_Status = CASE 
    WHEN Payment_Status = 'Yes' THEN 'Paid'
    WHEN Payment_Status = 'No' THEN 'Unpaid'
    ELSE Payment_Status
END;

UPDATE Billing
SET Payment_Status = CASE 
    WHEN LOWER(Payment_Status) = 'paid' THEN 'Paid'
    WHEN LOWER(Payment_Status) = 'unpaid' THEN 'Unpaid'
    WHEN LOWER(Payment_Status) = 'pending' THEN 'Pending'
    ELSE Payment_Status
END;

-- Standardize Payment_Method Values (Case & Format Normalization)
UPDATE Billing
SET Payment_Method = CASE 
    WHEN LOWER(Payment_Method) = 'cash' THEN 'Cash'
    WHEN LOWER(Payment_Method) = 'card' THEN 'Card'
    ELSE Payment_Method
END;

-- Standardize Discount_Applied Values (Case & Format Normalization)
UPDATE Billing
SET Discount_Applied = CASE 
    WHEN Discount_Applied = 'N' THEN 'No'
    WHEN Discount_Applied = 'Y' THEN 'Yes'
    ELSE Discount_Applied
END;

-- Replace NULL Misc_Code with Most Frequent Value (Mode Imputation)
UPDATE Billing
SET Misc_Code = (
    SELECT TOP 1 Misc_Code
    FROM Billing
    WHERE Misc_Code IS NOT NULL
    GROUP BY Misc_Code
    ORDER BY COUNT(*) DESC
)
WHERE Misc_Code IS NULL;

-- Data Clening for Medication Table

-- Standardize IDs Across Tables (Medication, Patients, Visits, etc.)
-- Format: PREFIX000X
ALTER TABLE Medication
ADD MedicationID VARCHAR(10);

UPDATE Medication
SET MedicationID =
    'MED' + RIGHT('0000' + 
        CAST(
            CAST(
                SUBSTRING(Medication_ID, PATINDEX('%[0-9]%', Medication_ID), LEN(Medication_ID))
            AS INT)
        AS VARCHAR), 4);

ALTER TABLE Medication
ADD PatientID VARCHAR(10)

UPDATE Medication
SET PatientID =
    'PAT' + RIGHT('0000' + 
        CAST(
            CAST(
                SUBSTRING(Patient_ID, PATINDEX('%[0-9]%', Patient_ID), LEN(Patient_ID))
            AS INT)
        AS VARCHAR), 4);

ALTER TABLE Medication
ADD VisitID VARCHAR(10)

UPDATE Medication
SET VisitID =
    'VIS' + RIGHT('0000' + 
        CAST(
            CAST(
                SUBSTRING(Visit_ID, PATINDEX('%[0-9]%', Visit_ID), LEN(Visit_ID))
            AS INT)
        AS VARCHAR), 4);

ALTER TABLE Medication
Drop column Medication_ID, Patient_ID, Visit_ID

-- Standardize Medication Frequency Values (Normalize All Formats)
UPDATE Medication
SET Frequency = CASE 
    WHEN LOWER(LTRIM(RTRIM(Frequency))) IN ('once daily', '1x/day') THEN 'Once daily'
    WHEN LOWER(LTRIM(RTRIM(Frequency))) IN ('twice daily', '2x/day') THEN 'Twice daily'
    ELSE Frequency
END;

-- Clean and normalize mixed date formats to ISO standard (YYYY-MM-DD)
ALTER TABLE Medication
ADD CleanMedication_Date VARCHAR(10);

UPDATE Medication
SET CleanMedication_Date =
    CONVERT(
        varchar(10),
        COALESCE(
            TRY_CONVERT(date, Start_Date, 101),
            TRY_CONVERT(date, Start_Date, 103),
            TRY_CONVERT(date, Start_Date, 111)
        ),
        23
    );

ALTER TABLE Medication
ADD CleanMedication_Date VARCHAR(10);

UPDATE Medication
SET CleanMedication_Date =
    CONVERT(
        varchar(10),
        COALESCE(
            TRY_CONVERT(date, End_Date, 101),
            TRY_CONVERT(date, End_Date, 103),
            TRY_CONVERT(date, End_Date, 111)
        ),
        23
    );

ALTER TABLE Medication
Drop column End_Date

EXEC sp_rename 'Medication.CleanMedication_Date', 'End_Date', 'COLUMN';

-- Data Clening for Patients Table

-- Standardize IDs for Patients
-- Format: PREFIX000X

ALTER TABLE Patients
ADD PatientID VARCHAR(10);

UPDATE Patients
SET PatientID =
    'PAT' + RIGHT('0000' + 
        CAST(
            CAST(
                SUBSTRING(Patient_ID, PATINDEX('%[0-9]%', Patient_ID), LEN(Patient_ID))
            AS INT)
        AS VARCHAR), 4);

ALTER TABLE Patients
Drop column Patient_ID 


-- Handle Invalid Date_of_Birth and Recalculate Age Safely
UPDATE p
SET p.Age = 
    DATEDIFF(YEAR, sub.DOB, GETDATE()) 
    - CASE 
        WHEN DATEADD(YEAR, DATEDIFF(YEAR, sub.DOB, GETDATE()), sub.DOB) > GETDATE()
        THEN 1 ELSE 0 
      END
FROM Patients p
JOIN (
    SELECT *,
        COALESCE(
            TRY_CONVERT(date, Date_of_Birth, 101),
            TRY_CONVERT(date, Date_of_Birth, 103),
            TRY_CONVERT(date, Date_of_Birth, 111)
        ) AS DOB
    FROM Patients
) sub ON p.PatientID = sub.PatientID   -- adjust if your PK is different
WHERE sub.DOB IS NOT NULL
AND (p.Age < 0 OR p.Age > 120);

UPDATE Patients
SET Date_of_Birth =
    CONVERT(
        VARCHAR(10),
        COALESCE(
            TRY_CONVERT(date, Date_of_Birth, 101),
            TRY_CONVERT(date, Date_of_Birth, 103),
            TRY_CONVERT(date, Date_of_Birth, 111)
        ),
        23
    );

-- Standardize Registration_Date ISO Format (YYYY-MM-DD)
UPDATE Patients
SET Registration_Date =
    CONVERT(
        VARCHAR(10),
        COALESCE(
            TRY_CONVERT(date, Registration_Date, 101),
            TRY_CONVERT(date, Registration_Date, 103),
            TRY_CONVERT(date, Registration_Date, 111)
        ),
        23
    );

-- Remove Asterisk (*) from Names
UPDATE Patients
SET Full_Name = REPLACE(Full_Name, '*', '');

-- Clean and standardize Gender values (MALE/FEMALE → Male/Female)
Update Patients
Set Gender = 
Case when Gender in ('MALE', 'male') then 'Male'
       when gender in ('FEMALE', 'female') then 'Female'
       Else Gender
End

-- Handle Missing Values in Contact & Address Fields
-- (Phone/Email → N/A, Full_Name/Address → Unknown)
UPDATE Patients
SET Full_name = 'Unknown'
WHERE Full_name IS NULL;

UPDATE Patients
SET Phone_number = 'N/A'
WHERE Phone_number IS NULL OR LTRIM(RTRIM(Phone_number)) = '';

UPDATE Patients
SET Email = 'N/A'
WHERE Email IS NULL OR LTRIM(RTRIM(Email)) = '';

UPDATE Patients
SET Address = 'Unknown'
WHERE Address IS NULL OR LTRIM(RTRIM(Address)) = '';

--Data Cleaning for Visits Table

-- Standardize IDs Across Tables (Visits, Patients)
-- Format: PREFIX000X

UPDATE Visits
SET Visit_ID =
    'VIS' + RIGHT('0000' + 
        CAST(
            CAST(
                SUBSTRING(Visit_ID, PATINDEX('%[0-9]%', Visit_ID), LEN(Visit_ID))
            AS INT)
        AS VARCHAR), 4);

EXEC sp_rename 'Visits.Visit_ID', 'VisitID', 'COLUMN';

UPDATE Visits
SET Patient_ID =
    'PAT' + RIGHT('0000' + 
        CAST(
            CAST(
                SUBSTRING(Patient_ID, PATINDEX('%[0-9]%', Patient_ID), LEN(Patient_ID))
            AS INT)
        AS VARCHAR), 4);

EXEC sp_rename 'Visits.Patient_ID', 'PatientID', 'COLUMN';

-- Standardize Admission_Date and Discharge_Date ISO Format (YYYY-MM-DD)
UPDATE Visits
SET Admission_Date =
    CONVERT(
        VARCHAR(10),
        COALESCE(
            TRY_CONVERT(date, Admission_Date, 101),
            TRY_CONVERT(date, Admission_Date, 103),
            TRY_CONVERT(date, Admission_Date, 111)
        ),
        23
    );

UPDATE Visits
SET Discharge_Date =
    CONVERT(
        VARCHAR(10),
        COALESCE(
            TRY_CONVERT(date, Discharge_Date, 101),
            TRY_CONVERT(date, Discharge_Date, 103),
            TRY_CONVERT(date, Discharge_Date, 111)
        ),
        23
    );

Update Visits
Set Reason_for_Visit = 
Case When Reason_for_Visit = 'checkup' then 'Checkup'
    Else Reason_for_Visit 
    End

Update Visits
Set Diagnosis = 
Case When Diagnosis = 'diabtes' then 'Diabetes'
    When Diagnosis = 'Hypertenson' then 'Hypertension'
    Else Diagnosis
    End





























