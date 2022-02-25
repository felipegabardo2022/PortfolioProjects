/*

Cleaning Data in SQL Queries

*/

Select * From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, Convert(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Alter Column SaleDate Date

--------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress, ISNULL(n1.PropertyAddress, n2.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing N1
join PortfolioProject.dbo.NashvilleHousing N2
	on N1.ParcelID = N2.ParcelID 
	and N1.[UniqueID ] <> N2.[UniqueID ]
where n1.PropertyAddress is null

Update N1
set n1.PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing N1
join PortfolioProject.dbo.NashvilleHousing N2
	on N1.ParcelID = N2.ParcelID 
	and N1.[UniqueID ] <> N2.[UniqueID ]
where n1.PropertyAddress is null



--------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns ( Address, City, State) using SUBSTRING

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


Alter Table  PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)  


Alter Table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--------------------------------------------------------------------------------------------------------

-- Breaking out Onwer Address into Individual Columns ( Address, City, State) using PARSENAME

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



Alter Table  PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Alter Table  PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Alter Table  PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing 
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)   

Update NashvilleHousing 
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)   

Update NashvilleHousing 
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)   

--------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = 
 CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				 ) row_num
From PortfolioProject.dbo.NashvilleHousing
)
delete FROM RowNumCTE
where Row_num >1 

WITH RowNumCTE AS (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				 ) row_num
From PortfolioProject.dbo.NashvilleHousing
) 
SELECT * FROM RowNumCTE
where Row_num >1 
order by PropertyAddress

--------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
select * From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate

