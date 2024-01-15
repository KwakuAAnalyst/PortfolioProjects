----------------------------------------------------------------------------------------------------------------------------------------
/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.DataCleaning

----------------------------------------------------------------------------------------------------------------------------------------

/*

Standard format for Sale Date

*/

Select NewSaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.DataCleaning

Update DataCleaning
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE DataCleaning
ADD NewSaleDate Date;

Update DataCleaning
SET NewSaleDate = CONVERT(Date,SaleDate)


----------------------------------------------------------------------------------------------------------------------------------------
/*

Populate Property Address

*/

Select *
From PortfolioProject.dbo.DataCleaning
--Where PropertyAddress is null
order by ParcelID

Select o.ParcelID, o.PropertyAddress, n.ParcelID, n.PropertyAddress, ISNULL(o.PropertyAddress, n.PropertyAddress)
From PortfolioProject.dbo.DataCleaning o
JOIN PortfolioProject.dbo.DataCleaning n
	on o.ParcelID = n.ParcelID
	AND o.[UniqueID ] <> n.[UniqueID ]
Where o.PropertyAddress is null

Update o
SET PropertyAddress = ISNULL(o.PropertyAddress, n.PropertyAddress)
From PortfolioProject.dbo.DataCleaning o
JOIN PortfolioProject.dbo.DataCleaning n
	on o.ParcelID = n.ParcelID
	AND o.[UniqueID ] <> n.[UniqueID ]
Where o.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------------
/*

Splitting columns for PropertyAddress (Address, City, State)

*/

Select PropertyAddress
From PortfolioProject.dbo.DataCleaning

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City 


From PortfolioProject.dbo.DataCleaning



ALTER TABLE [PortfolioProject].[dbo].[DataCleaning]
ADD PropertySplitAddress Nvarchar(255);

Update [PortfolioProject].[dbo].[DataCleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [PortfolioProject].[dbo].[DataCleaning]
ADD PropertySplitCity Nvarchar(255);

Update [PortfolioProject].[dbo].[DataCleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.DataCleaning

------------------------------------------------------------------------------------------------------------------------------------------
/*

Splitting columns for OwnerAddress (Address, City, State)

*/

Select *
From PortfolioProject.dbo.DataCleaning

Select OwnerAddress
From PortfolioProject.dbo.DataCleaning


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State

From PortfolioProject.dbo.DataCleaning



ALTER TABLE [PortfolioProject].[dbo].[DataCleaning]
ADD OwnerSplitAddress Nvarchar(255);

Update [PortfolioProject].[dbo].[DataCleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE [PortfolioProject].[dbo].[DataCleaning]
ADD OwnerSplitCity Nvarchar(255);

Update [PortfolioProject].[dbo].[DataCleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE [PortfolioProject].[dbo].[DataCleaning]
ADD OwnerSplitState Nvarchar(255);

Update [PortfolioProject].[dbo].[DataCleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


----------------------------------------------------------------------------------------------------------------------------------------
/*

Change  Y and N to Yes and No in "Sold as Vacant" field

*/

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.DataCleaning
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
From PortfolioProject.dbo.DataCleaning


Update DataCleaning
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


----------------------------------------------------------------------------------------------------------------------------------------
/*

Remove Duplicates

*/

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.DataCleaning
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress
----------------------------------------------------------------------------------------------------------------------------------------
/*

Delete unused columns 

*/

Select *
From PortfolioProject.dbo.DataCleaning

ALTER TABLE PortfolioProject.dbo.DataCleaning
DROP COLUMN OwnerAddress, TaxDistrict, SaleDate, PropertyAddress

----------------------------------------------------------------------------------------------------------------------------------------
