/* Clean data with SQL querries */

SELECT *
FROM NasvilleHousing

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NasvilleHousing

UPDATE NasvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NasvilleHousing
ADD SaleDateConverted Date

UPDATE NasvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NasvilleHousing

-- Populate Property Address data
SELECT *
FROM NasvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NasvilleHousing a
JOIN NasvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NasvilleHousing a
JOIN NasvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NasvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM NasvilleHousing

ALTER TABLE NasvilleHousing
ADD PropertySplitAdress nvarchar(255)

UPDATE NasvilleHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NasvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NasvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM NasvilleHousing

SELECT OwnerAddress
FROM NasvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NasvilleHousing

ALTER TABLE NasvilleHousing
ADD OwnerSplitAdress nvarchar(255)

UPDATE NasvilleHousing
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NasvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NasvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NasvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NasvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM NasvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NasvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM NasvilleHousing

UPDATE NasvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NasvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	ORDER BY UniqueID) row_num
FROM NasvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	ORDER BY UniqueID) row_num
FROM NasvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	ORDER BY UniqueID) row_num
FROM NasvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns

SELECT *
FROM NasvilleHousing

ALTER TABLE NasvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict