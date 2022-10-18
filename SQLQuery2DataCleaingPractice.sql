-- Cleaning data 
Select *
FROM [rooster 1].[dbo].[NashHousing]

-- Srandardize Data format 
-- create new column
ALTER TABLE NashHousing
Add SaleDateConverted Date;

Update NashHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Property Address data
Select *
From [rooster 1].[dbo].[NashHousing]
order by ParcelID

--ParcelID matches PropertyAddress 
--When ParcelID has a null address we must match it with correct Propertyaddress

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From [rooster 1].[dbo].[NashHousing] a
JOIN [rooster 1].[dbo].[NashHousing] b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
Where a.PropertyAddress is null
 
 -- if null we will populate with Property Address
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [rooster 1].[dbo].[NashHousing] a
JOIN [rooster 1].[dbo].[NashHousing] b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
Where a.PropertyAddress is null

--update by replacing the nulls

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [rooster 1].[dbo].[NashHousing] a
JOIN [rooster 1].[dbo].[NashHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--breaking out the address inot individual columsn
-- a delimiter (,) will help seperate the data 
Select PropertyAddress
From [rooster 1].[dbo].[NashHousing]

--Substring and a character Index
--read as a numerical value minus 1 removes the , 
-- CHARINDEX -This function searches for one character expression inside a second character expression, returning the starting position of the first expression if found.
select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From [rooster 1].[dbo].[NashHousing]

--read as a numerical value +1 also removes the , before city address
select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address
From [rooster 1].[dbo].[NashHousing]

--adds column in data naming it Propertysplitaddress
ALTER TABLE NashHousing
Add Propertysplitaddress Nvarchar(255);

--
Update NashHousing
SET Propertysplitaddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

--adds column in data naming it Propertysplitcity
ALTER TABLE NashHousing
Add Propertysplitcity Nvarchar(255);

--
Update NashHousing
SET Propertysplitcity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

--read newly added data
Select *
FROM [rooster 1].[dbo].[NashHousing]

-- another way of spliting data 
-- example on OwnerAddress columns 

Select OwnerAddress
FROM [rooster 1].[dbo].[NashHousing]

--PARSENAME - Returns the specified part of an object name. The parts of an object that can be retrieved are the object name, schema name, database name, and server name.
-- only used with period so we must replace , with .
--Replace The REPLACE() function replaces all occurrences of a substring within a string, with a new substring. ex. REPLACE(string, old_string, new_string)

select
PARSENAME(replace(OwnerAddress,',','.'), 1)
FROM [rooster 1].[dbo].[NashHousing]

--add add the columns 
select
PARSENAME(replace(OwnerAddress,',','.'), 3),
PARSENAME(replace(OwnerAddress,',','.'), 2),
PARSENAME(replace(OwnerAddress,',','.'), 1)
FROM [rooster 1].[dbo].[NashHousing]

-- add columns into data
--adds column in data naming it ownersplitaddress
ALTER TABLE NashHousing
Add ownersplitaddress Nvarchar(255);


Update NashHousing
SET ownersplitaddress = PARSENAME(replace(OwnerAddress,',','.'), 3)

--adds column in data naming it ownersplitcity
ALTER TABLE NashHousing
Add ownersplitcity Nvarchar(255);

Update NashHousing
SET ownersplitcity = PARSENAME(replace(OwnerAddress,',','.'), 2)

--adds column in data naming it ownersplitstate
ALTER TABLE NashHousing
Add ownersplitstate Nvarchar(255);

Update NashHousing
SET ownersplitstate = PARSENAME(replace(OwnerAddress,',','.'), 1)

--read newly added data
Select *
FROM [rooster 1].[dbo].[NashHousing]

--When "Sold as Vacant" replace the Y and N to Yes and No
Select distinct(SoldAsVacant), count(SoldAsVacant)
FROM [rooster 1].[dbo].[NashHousing]
group by SoldAsVacant
order by 2

Select SoldAsVacant, 
Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
FROM [rooster 1].[dbo].[NashHousing]

update [rooster 1].[dbo].[NashHousing]
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
	 FROM [rooster 1].[dbo].[NashHousing]

Select distinct(SoldAsVacant), count(SoldAsVacant)
FROM [rooster 1].[dbo].[NashHousing]
group by SoldAsVacant
order by 2


--Remove Duplicates
With RownumCTE as(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by 
			 UniqueId
			 )
			 Row_num

FROM [rooster 1].[dbo].[NashHousing]
)
Select *
from RownumCTE


-- helps us find duplicates

With RownumCTE as(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by 
			 UniqueId
			 )
			 Row_num

FROM [rooster 1].[dbo].[NashHousing]
)
Select *
from RownumCTE
where Row_num > 1
order by PropertyAddress

-- helps u delete duplicte
With RownumCTE as(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by 
			 UniqueId
			 )
			 Row_num

FROM [rooster 1].[dbo].[NashHousing]
)
delete
from RownumCTE
where Row_num > 1

-- duplicates are deleted check with the last code

-- Delete Used Columns
-- can use as many names to delete
Select *
FROM [rooster 1].[dbo].[NashHousing]

alter table [rooster 1].[dbo].[NashHousing]
drop column owneraddress, taxDistrict, PropertyAddress

-- looking back no piont in having sale date but must crate a new line once previous has been completed 
alter table [rooster 1].[dbo].[NashHousing]
drop column SaleDate

