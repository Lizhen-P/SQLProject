USE PortfolioProject

SELECT * FROM NashvilleHousing

SELECT SaleDate FROM NashvilleHousing

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing

-- ALTER TABLE NashvilleHousing
-- DROP COLUMN SaleDateConverted

SELECT * 
FROM NashvilleHousing
ORDER BY ParcelID

-- self join on ParcelID to fill in missing PropertyAddress for some duplicated ParcelID
-- check first
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
FROM NashvilleHousing a 
JOIN NashvilleHousing b 
    ON a.ParcelID = b.ParcelID
    WHERE a.UniqueID <> b.UniqueID
    AND a.PropertyAddress IS NULL

-- update the missing PropertyAddress values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b 
    ON a.ParcelID = b.ParcelID
    WHERE a.UniqueID <> b.UniqueID
    AND a.PropertyAddress IS NULL

-- check if there is still missing value in PropertyAddress
SELECT UniqueID
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

-- Parsing PropertyAddress
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD 
    Address NVARCHAR(255),
    City NVARCHAR(255)

UPDATE NashvilleHousing
SET 
    Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
    City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))

-- Parsing OwnerAddress using PARSENAME
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD 
    OwnerSplitAddress NVARCHAR(255),
    OwnerCity NVARCHAR(255),
    OwnerState NVARCHAR(255)

UPDATE NashvilleHousing
SET
    OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldasVacant), COUNT(SoldasVacant)
FROM NashvilleHousing
GROUP BY SoldasVacant
ORDER BY 2

SELECT SoldasVacant
, CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
       WHEN SoldasVacant = 'N' THEN 'No'
       ELSE SoldasVacant
       END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldasVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
                        WHEN SoldasVacant = 'N' THEN 'No'
                        ELSE SoldasVacant
                        END

-- Remove Duplicates

-- finding duplicates
SELECT * ,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                 UniqueID) row_num
FROM NashvilleHousing
ORDER BY ParcelID

-- using CTE to check how many duplicates are there
WITH RowNumCTE AS (
    SELECT * ,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                 UniqueID) row_num
FROM NashvilleHousing
-- ORDER BY ParcelID    
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY UniqueID

-- delete the duplicates
WITH RowNumCTE AS (
    SELECT * ,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                 UniqueID) row_num
FROM NashvilleHousing  
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- check for duplicates after deletion
WITH RowNumCTE AS (
    SELECT * ,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                 UniqueID) row_num
FROM NashvilleHousing   
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY UniqueID

-- delete unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate