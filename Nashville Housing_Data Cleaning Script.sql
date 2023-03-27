--Data Cleaning
SELECT * 
FROM Project.dbo.[Nashville Housing Data for Data Cleaning]

---Populate PropertyAddress

SELECT *
FROM Project.dbo.[Nashville Housing Data for Data Cleaning]


  

SELECT  A.UniqueID, A.ParcelID, A.PropertyAddress,B.UniqueID, B.ParcelID,  B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] A
JOIN Project.dbo.[Nashville Housing Data for Data Cleaning] B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

UPDATE A 
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Project.dbo.[Nashville Housing Data for Data Cleaning] A
JOIN Project.dbo.[Nashville Housing Data for Data Cleaning] B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

---SPLITING THE ADDRESS
--USING SUBSTRING

SELECT PropertyAddress
FROM Project.dbo.[Nashville Housing Data for Data Cleaning]
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1 )as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
FROM Project.dbo.[Nashville Housing Data for Data Cleaning]
 
 ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning]
 ADD PropertySplitAddress NVARCHAR(255);

 UPDATE Project.dbo.[Nashville Housing Data for Data Cleaning]
 SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning]
 ADD PropertySplitCity NVARCHAR(255);

 UPDATE Project.dbo.[Nashville Housing Data for Data Cleaning]
 SET PropertySplitCity  = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))


 ----USING PARSE NAME
 SELECT OwnerAddress
FROM Project.dbo.[Nashville Housing Data for Data Cleaning]

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS HomeAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS CityAdress,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS StateAddress
FROM Project.dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning]
 ADD HomeAddress NVARCHAR(255);

 UPDATE Project.dbo.[Nashville Housing Data for Data Cleaning]
 SET  HomeAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning]
 ADD CityAdress NVARCHAR(255);

 UPDATE Project.dbo.[Nashville Housing Data for Data Cleaning]
 SET CityAdress  = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 


ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning]
 ADD StateAddress NVARCHAR(255);

 UPDATE Project.dbo.[Nashville Housing Data for Data Cleaning]
 SET StateAddress  = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

 --Changing Y and N to Yes and No
SELECT Distinct(SoldAsVacant)
FROM Project.dbo.[Nashville Housing Data for Data Cleaning]

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project.dbo.[Nashville Housing Data for Data Cleaning]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y'
        THEN 'Yes'
 WHEN SoldAsVacant = 'N'
        THEN 'No'
ELSE  SoldAsVacant
END
FROM Project.dbo.[Nashville Housing Data for Data Cleaning]

 UPDATE Project.dbo.[Nashville Housing Data for Data Cleaning]
 SET SoldAsVacant  = CASE WHEN SoldAsVacant = 'Y'
        THEN 'Yes'
 WHEN SoldAsVacant = 'N'
        THEN 'No'
ELSE  SoldAsVacant
END

--Removing Duplicates
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION  BY
    ParcelID,
    LandUse,
    PropertyAddress,
    SaleDate,
    SalePrice,
    LegalReference ORDER BY UniqueID
) as Row_Num
FROM Project.dbo.[Nashville Housing Data for Data Cleaning]
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1


---DELETING UNUSED COLUMN

SELECT *
FROM Project.dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE Project.dbo.[Nashville Housing Data for Data Cleaning]
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict


