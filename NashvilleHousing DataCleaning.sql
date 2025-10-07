/*
🧹 Data Cleaning in SQL – Nashville Housing Dataset
📘 Overview
This project focuses on cleaning and preparing a housing dataset in SQL Server to ensure accuracy, consistency, and readiness for analysis and visualisation. 
The raw dataset included irregular date formats, missing property details, inconsistent categorical entries, 
and duplicate records, all of which were systematically addressed using SQL queries.
⚙️ Key Steps and Techniques
Standardised Date Formats – Converted inconsistent SaleDate values into a uniform SQL DATE format.
Populated Missing Addresses – Filled missing PropertyAddress values by joining rows with matching ParcelID identifiers.
Parsed Address Fields – Split combined property and owner addresses into distinct columns for Address, City, and State using string manipulation functions (SUBSTRING, CHARINDEX, and PARSENAME).
Normalised Categorical Data – Replaced shorthand values (‘Y’/‘N’) in the SoldAsVacant field with standardised terms (‘Yes’/‘No’) for consistency.
Removed Duplicates – Used a Common Table Expression (CTE) with the ROW_NUMBER() function to detect and delete duplicate entries.
Dropped Redundant Columns – Cleaned up unnecessary columns (OwnerAddress, TaxDistrict, etc.) to streamline the dataset.
🧩 Outcome
The cleaned dataset was fully standardised and free of duplicates, making it suitable for exploratory data analysis and dashboard creation in Power BI or Tableau. 
This process demonstrates my ability to write efficient SQL queries for data wrangling, integrity checks, and transformation — key skills for any data analytics workflow.
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format
Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

--Populating the Property Address Data
--Step 1 to analyse the data
Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--Step 2 join the table to its self but to find parcel id but make sure its not the same row through unique id
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Step 3 to update the coloumns and run step 2 again to double check
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Dividing Address into individual coloumns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

--Charindex to identify the comma to separate, -1 to remove comma value, +1 to pick character after comma
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing


--Doing the same for owner address using parsename (replacing comma with fullstop)
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress Nvarchar(255);
Alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity Nvarchar(255);
Alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)
Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)
Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

Select *
From PortfolioProject.dbo.NashvilleHousing


--Changing Y & N to Yes & No in "Sold as Vacant" field
--Step 1 check the distict values count
Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


--Removing Duplicates from data using CTE
With RowNumCTE AS(
Select *, 
	ROW_NUMBER() over (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Delete
From RowNumCTE
Where row_num >1


--Delete Unused Coloumns

Select *
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioProject.dbo.NashvilleHousing

DROP COLUMN SaleDate
