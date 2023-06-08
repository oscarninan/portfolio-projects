
-- Cleaning Data in SQL Queries

SELECT *
FROM Portfolio..NashvilleHousing

-- Standardize the Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date

-- Populate Property Address Column where NULL

SELECT *
FROM Portfolio..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Addresses into Individual Columns (Address, City State)

SELECT PropertyAddress
FROM Portfolio..NashvilleHousing

SELECT CHARINDEX(',', PropertyAddress)
FROM Portfolio..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress) - 1)) AS Address,
SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress) + 1),LEN(PropertyAddress)) As City
FROM Portfolio..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropAddress = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress) - 1))

ALTER TABLE NashvilleHousing
Add PropCity nvarchar(255);

UPDATE NashvilleHousing
SET PropCity = SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress) + 1),LEN(PropertyAddress))


SELECT *
FROM Portfolio..NashvilleHousing

SELECT OwnerAddress
FROM Portfolio..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Portfolio..NashvilleHousing


ALTER TABLE NashvilleHousing
Add Owner_Address nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
Add Owner_Address_City nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Address_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHousing
Add Owner_Address_State nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Address_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No respectively in "SoldAsVacant column"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Portfolio..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	Row_Number() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
	) row_num
FROM Portfolio..NashvilleHousing
)
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Delete Unused Columns

SELECT *
FROM Portfolio..NashvilleHousing

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN PropertyAddress