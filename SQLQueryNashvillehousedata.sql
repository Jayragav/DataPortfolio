SELECT *
FROM Portfolioproject.dbo.NashvilleHousing
--------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Portfolioproject.dbo.NashvilleHousing as NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted from NashvilleHousing
------------------------------------------------
-- Getting the Property Address in  the desired format

SELECT a.parcelId,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress =ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------
-- Splitting Address into Individual Columns of Address,City

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyAddressSplit NVarchar(255)

UPDATE NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

SELECT PropertyAddressSplit 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyAddressCity NVarchar(255)

UPDATE NashvilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
FROM NashvilleHousing

SELECT PropertyAddressCity
FROM NashvilleHousing

---------------------------------------------------------------------------------
--Splitting Owner Address into Address,City and State

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)

SELECT OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
FROM NashvilleHousing

-----------------------------------------------------------------------------
--Changing Y and N to Yes and No in SoldAsVacant field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
WHEN SoldAsVacant ='N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
WHEN SoldAsVacant ='N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing

--Remove Duplicates
WITH RowNumCte AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			 UniqueID
			 ) row_num

FROM Portfolioproject.dbo.NashvilleHousing
)
DELETE 
FROM RowNumCte
WHERE row_num>1

-----------------------------------------------------------------------------
Delete Unused Columns

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

SELECT *
FROM Portfolioproject.dbo.NashvilleHousing

-----------------------------------------------------------------------------