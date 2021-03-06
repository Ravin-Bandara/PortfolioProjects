CREATE TABLE NashvilleHousing(
UniqueID varchar(255),
ParcelID varchar(255),
LandUse	varchar(255),
PropertyAddress	varchar(255),
SaleDate date,
SalePrice	varchar(255),
LegalReference varchar(255),
SoldAsVacant	varchar(255),
OwnerName	varchar(255),
OwnerAddress	varchar(255),
Acreage	varchar(255),
TaxDistrict varchar(255),
LandValue	varchar(255),
BuildingValue	varchar(255),
TotalValue varchar(255),
YearBuilt	varchar(255),
Bedrooms varchar(255),
FullBath	varchar(255),
HalfBath varchar(255));



-- Standardize Date Format


ALTER TABLE NashvilleHousing
Add SALEDATEConverted Date;

UPDATE NashvilleHousing
SET SALEDATE = CONVERT(Date, SALEDATE);

-- Populate Property Address Data

SELECT *
From nashvillehousing
WHERE propertyaddress is null
order by ParcelID;

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, NVL(a.propertyaddress, b.propertyaddress)
From nashvillehousing a
JOIN nashvillehousing b
    on a.parcelid = b.parcelid
    and a.uniqueid <> b.uniqueid
where a.propertyaddress is null;


UPDATE NashvilleHousing dst
SET propertyaddress = (
  SELECT src.propertyaddress
  FROM   NashvilleHousing src
  WHERE  dst.parcelid = src.parcelid
  AND    dst.uniqueid <> src.uniqueid
  AND    src.propertyaddress IS NOT NULL
  AND    ROWNUM = 1
)
WHERE propertyaddress IS NULL;

-- Breaking out address into individual columns (address, city, state)

SELECT PropertyAddress
From nashvillehousing;
--WHERE propertyaddress is null
--order by ParcelID;

SELECT 
SUBSTR(PropertyAddress, 1, instr(propertyaddress, ',')-1) as Address
, SUBSTR(PropertyAddress, INSTR(propertyaddress, ',')+1, LENGTH(PropertyAddress)) as Address
FROM nashvillehousing;


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar2(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTR(PropertyAddress, 1, instr(propertyaddress, ',')-1);


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar2(255);


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTR(PropertyAddress, INSTR(propertyaddress, ',')+1, LENGTH(PropertyAddress));



SELECT
regexp_substr(owneraddress, '[^,]+', 1,1) as part_1,
regexp_substr(owneraddress, '[^,]+', 1,2) as part_2,
regexp_substr(owneraddress, '[^,]+', 1,3) as part_3
From nashvillehousing;


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar2(255);


UPDATE NashvilleHousing
SET OwnerSplitAddress = regexp_substr(owneraddress, '[^,]+', 1,1);


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar2(255);


UPDATE NashvilleHousing
SET OwnerSplitCity = regexp_substr(owneraddress, '[^,]+', 1,2);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar2(255);

Update NashvilleHousing
SET OwnerSplitState = regexp_substr(owneraddress, '[^,]+', 1,3);

ALTER TABLE NashvilleHousing
DROP COLUMN Owndersplitstate;



-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2;

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing;


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;
       
-- Remove Duplicates

DELETE FROM nashvillehousing
WHERE ROWID IN(
WITH RowNumCTE (t)AS(
SELECT  ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                SalePrice,
                LegalReference,
                SaleDate,
                PropertyAddress
                ORDER BY
                    UniqueID
)     
FROM nashvillehousing 
--Order by parcelid
) 
SELECT ROWID
FROM RowNumCTE
WHERE t > 1)
;

-- Delete Unused Columns


ALTER TABLE nashvillehousing
DROP (OwnerAddress, TaxDistrict, PropertyAddress);

ALTER TABLE nashvillehousing
DROP COLUMN SaleDate;

Select *
FROM nashvillehousing;
