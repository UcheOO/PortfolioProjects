/*
Cleaning Data in SQL Queries Nashville Housing crisis.
*/


Select *
From SqlProject..Nashville

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
from SqlProject..Nashville


Select saleDateConverted, CONVERT(Date,SaleDate)
From SqlProject..Nashville


Update Nashville
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE Nashville
Add SaleDateConverted Date;

Update Nashville
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From SqlProject..Nashville
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From SqlProject..Nashville a
JOIN SqlProject..Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From SqlProject..Nashville a
JOIN SqlProject..Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From SqlProject..Nashville
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From SqlProject..Nashville


ALTER TABLE Nashville
Add PropertySplitAddress Nvarchar(255);

Update Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Nashville
Add PropertySplitCity Nvarchar(255);

Update Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From SqlProject..Nashville





Select OwnerAddress
From SqlProject..Nashville

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From SqlProject..Nashville


ALTER TABLE Nashville
Add OwnerSplitAddress Nvarchar(255);

UPDATE Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Nashville
Add OwnerSplitCity Nvarchar(255);

UPDATE Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Nashville
Add OwnerSplitState Nvarchar(255);

UPDATE Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From SqlProject..Nashville


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From SqlProject..Nashville
Group by SoldAsVacant
order by 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From SqlProject..Nashville


UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


	-- Remove Duplicates with CTE

	with RowNumCTE AS(

	SELECT *,
		ROW_NUMBER()OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
							UniqueID
							) row_num
	From SqlProject..Nashville
	--order by ParcelID
	)

	select *
	FROM RowNumCTE
	WHERE row_num > 1
	--order by PropertyAddress



-- Delete Unused Columns

Select *
From SqlProject..Nashville

ALTER TABLE SqlProject..Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate