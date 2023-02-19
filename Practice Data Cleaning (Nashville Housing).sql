



--Standardized Date Format

Select SaleDate, Convert(Date, Saledate)
From PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = Convert(Date, Saledate)

-----------------------------------Experimenting--------------------------------
ALTER TABLE NashvilleHousing
ADD SalesDateConverted Date;

UPDATE NashvilleHousing
SET SalesDateConverted = Convert(Date, Saledate)


Select SalesDateConverted, Convert(Date, Saledate)
From PortfolioProjects..NashvilleHousing




------------------------------------------------------------------------------------------------------------------------------------.
--Populate Property Address Data

Select *
From PortfolioProjects..NashvilleHousing
--Where PropertyAddress is Null
order by ParcelID


-----------------------Joining within the table with unique ID but have the same Parcel ID yet Property Address of some are null-------------------------------------
Select a.ParcelId, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects..NashvilleHousing as a
JOIN PortfolioProjects..NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress =ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects..NashvilleHousing as a
JOIN PortfolioProjects..NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null



------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address Into Individual Columns (Adress, City, State)



Select *
From PortfolioProjects..NashvilleHousing
--Where PropertyAddress is Null
--order by ParcelID


----------------triming the address from its CIty-----------------------------------------------------------------
SELECT 
Substring(PropertyAddress, 1, Charindex (',', PropertyAddress) -1) as Address
, Substring(PropertyAddress, Charindex (',', PropertyAddress) +1, LEN(PropertyAddress))as Address
From PortfolioProjects..NashvilleHousing

-------------------------updating the table with the trimmed address----------------------------------------------
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, Charindex (',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, Charindex (',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
FROM PortfolioProjects..NashvilleHousing



-------------------simpler way -----------------------------------------------------------------------------------------------------
Select OwnerAddress
FROm PortfolioProjects..NashvilleHousing

Select
PARSENAME(Replace (OwnerAddress, ',', '.'),3) 
, PARSENAME(Replace (OwnerAddress, ',', '.'),2)
, PARSENAME(Replace (OwnerAddress, ',', '.'),1)
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace (OwnerAddress, ',', '.'),3) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace (OwnerAddress, ',', '.'),2) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace (OwnerAddress, ',', '.'),1)


Select *
FROM PortfolioProjects..NashvilleHousing



------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to YES and NO in "Sold as Vacant" field

Select distinct (SoldAsVacant), Count(SoldasVacant)
FROM PortfolioProjects..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, Case When SoldasVacant = 'Y' Then 'YES'
		When SoldasVacant = 'N' THEN 'No'
		Else SOldasVacant
END
FROM PortfolioProjects..NashvilleHousing


Update NashvilleHousing
SET SoldasVacant =  Case When SoldasVacant = 'Y' Then 'YES'
		When SoldasVacant = 'N' THEN 'No'
		Else SOldasVacant
END

------------------------------------------------------------------------------------------------------------------------------------


--Remove Duplicates
With RowNUMCTE AS(
Select *,
	ROW_NUmber() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 Order BY
					UniqueID
					) as row_num
From PortfolioProjects..NashvilleHousing
--order by ParcelID
)
------DELETE IT WITH THIS (Get rid of the order by)-------
Select *
FROm RowNUMCTE
Where row_num > 1
Order by PropertyAddress

------------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Column

Select *
From PortfolioProjects..NashvilleHousing

ALTER Table PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER Table PortfolioProjects..NashvilleHousing
DROP COLUMN Saledate