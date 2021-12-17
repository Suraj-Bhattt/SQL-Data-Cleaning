--Lets begin DATA CLEANING

Select * 
from [Data Cleaning]..[Nashvilla Housing]

-- Standardize Date Format

Select Saledateconverted, CONVERT(date, Saledate)
from [Data Cleaning]..[Nashvilla Housing]

update [Nashvilla Housing]
set SaleDate = CONVERT(date, Saledate)

ALTER TABLE [Nashvilla Housing]
add saledateconverted date;

update [Nashvilla Housing]
set saledateconverted = CONVERT(date, Saledate)


--Populate property address data

Select *
from [Data Cleaning]..[Nashvilla Housing]
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Data Cleaning]..[Nashvilla Housing] a
join [Data Cleaning]..[Nashvilla Housing] b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Data Cleaning]..[Nashvilla Housing] a
join [Data Cleaning]..[Nashvilla Housing] b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]


--Breaking out address into individual columns (address, city, state)

Select PropertyAddress
from [Data Cleaning]..[Nashvilla Housing]
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as address
from [Data Cleaning]..[Nashvilla Housing]

ALTER TABLE [Nashvilla Housing]
add PropertysplitAddress nvarchar(255);

update [Nashvilla Housing]
set PropertysplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Nashvilla Housing]
add PropertysplitCity nvarchar(255);

update [Nashvilla Housing]
set PropertysplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))

select *
from [Data Cleaning]..[Nashvilla Housing]

--ALTERNATE way of breaking out the adress in different columns

--select
--PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2),
--PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1)
--from [Data Cleaning]..[Nashvilla Housing]


--Now Lets Breakout the owner address

Select OwnerAddress
from [Data Cleaning]..[Nashvilla Housing]

select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from [Data Cleaning]..[Nashvilla Housing]

ALTER TABLE [Nashvilla Housing]
add OwnersplitAddress nvarchar(255);

update [Nashvilla Housing]
set OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Nashvilla Housing]
add OwnersplitCity nvarchar(255);

update [Nashvilla Housing]
set OwnersplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Nashvilla Housing]
add OwnersplitState nvarchar(255);

update [Nashvilla Housing]
set OwnersplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select *
from [Data Cleaning]..[Nashvilla Housing]


--Change Y and N to "YES" and "NO" in "Sold as Vacant" Field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Data Cleaning]..[Nashvilla Housing]
Group by SoldAsVacant
Order by 2


select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from [Data Cleaning]..[Nashvilla Housing]

update [Data Cleaning]..[Nashvilla Housing]
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- REMOVE DUPLICATES

WITH RowNumCTE AS(
select *,
      ROW_NUMBER() over (
	  PARTITION BY ParcelID,
				   PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY
						UniqueID
						) row_num

From [Data Cleaning]..[Nashvilla Housing]
--order by ParcelID
)
Select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


select *
from [Data Cleaning]..[Nashvilla Housing]


-- Delete Unused Columns

select *
from [Data Cleaning]..[Nashvilla Housing]

alter table [Data Cleaning]..[Nashvilla Housing]
Drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table [Data Cleaning]..[Nashvilla Housing]
Drop column SaleDate