/*	
Data_Điều tra dân số 10 tỉnh thành năm 2019 
	
Các kỹ năng được sử dụng: Aggregate Functions, CTE's, Temp Tables, Windows Functions, Creating Views
*/

Select *
From PortfolioProjects..Demographic10provinces
Where Tinh is not null

-- Thêm cột DanSo 
ALTER TABLE Demographic10provinces
Add DanSo numeric;

UPDATE Demographic10provinces
SET DanSo = Nam + Nu

-- 1) Thống kê theo giới tính

	-- 1.1) Tỷ lệ nam/nữ tại từng tỉnh (So sánh giữa các tỉnh)
Select Tinh, 
SUM(Nam) As SoNam, 
SUM(Nu) As SoNu, 
SUM(DanSo) As DanSoTheoTinh, 
SUM(Nam)/SUM(DanSo)*100 As TyLeNam, 
SUM(Nu)/SUM(DanSo)*100 As TyLeNu
From PortfolioProjects..Demographic10provinces 
Where Tinh is not null
Group By Tinh
Order By 4 DESC

	-- 1.2) Tỷ lệ nam/nữ tại từng huyện (So Sánh giữa các huyện trong 1 tỉnh)
		-- Create Table Gender_Huyen
DROP Table if exists Gender_Huyen

Create Table Gender_Huyen
(
Tinh nvarchar(225),
Huyen nvarchar(225),
SoNam numeric,
SoNu numeric,
DanSoTheoHuyen numeric,
)
Insert into Gender_Huyen
Select Tinh, Huyen, SUM(Nam) As SoNam, SUM(Nu) As SoNu, SUM(DanSo) As DanSoTheoHuyen
From PortfolioProjects..Demographic10provinces 
Where Tinh is not null
Group By Tinh, Huyen
Order By 1 DESC

Select * 
From Gender_Huyen

		-- Tỷ lệ nam/nữ và tỷ lệ dân số của các huyện trong 1 tỉnh
With Gender As
(
Select Tinh, Huyen,
SoNam, SUM(SoNam) OVER (PARTITION BY Tinh) As SoNamToanTinh, 
SoNu, SUM(SoNu) OVER (PARTITION BY Tinh) As SoNuToanTinh, 
DanSoTheoHuyen, SUM(DanSoTheoHuyen) OVER (PARTITION BY Tinh) As DanSoTheoTinh
From Gender_Huyen 
)
Select *,
SoNam/SoNamToanTinh*100 As TyLeNam,
SoNu/SoNuToanTinh*100 As TyLeNu,
DanSoTheoHuyen/DanSoTheoTinh*100 As TyleDanSo
From Gender
Order By 1 DESC

-- 2) Thống kê theo độ tuổi
With Age As 
(
Select Tinh, Huyen, Xa, 
DanSo, 
NuDuoi15t + NamDuoi15t As Duoi15t, 
Nu_15_60t + Nam_15_60t As Tu15_60t, 
NuTren60t + NamTren60t As Tren60t
From PortfolioProjects..Demographic10provinces 
Where Tinh is not null
)
Select Tinh, 
SUM(DanSo) As DanSoTheoTinh, SUM(Duoi15t) As Duoi15t, SUM(Tu15_60t) As Tu15_60t, SUM(Tren60t) As Tren60t, 
SUM(Duoi15t)/SUM(DanSo)*100 As TyLeDuoi15t, SUM(Tu15_60t)/SUM(DanSo)*100 As TyLeTu15_60t, SUM(Tren60t)/SUM(DanSo)*100 As TyLeTren60t
From Age
Group By Tinh
Order By 2 DESC

-- 3) Thống kê theo giáo dục

	--3.1) Tạo table Education
DROP Table if exists Education

Create Table Education
(
Tinh nvarchar(225),
DanSoTheoTinh numeric,
TieuHoc numeric,
THCS numeric,
THPT numeric,
CaoDang numeric,
DaiHoc numeric,

)
Insert into Education
Select Tinh, SUM(DanSo) As DanSoTheoTinh, SUM(TieuHoc) As TieuHoc, SUM(THCS) As THCS, SUM(THPT) As THPT, SUM(CaoDang) As CaoDang, SUM(DaiHoc) As DaiHoc
From PortfolioProjects..Demographic10provinces 
Where Tinh is not null
Group By Tinh

Select *
From Education

	-- 3.2) Thống kê tỷ lệ học sinh trung học và tỷ lệ sinh viên hệ cao đẳng, đại học theo tỉnh trên dân số toàn tỉnh
With Student As
(
Select Tinh, DanSoTheoTinh, THCS + THPT As HsTrungHoc, CaoDang + DaiHoc As SinhVien
From Education
)
Select *, HsTrungHoc/DanSoTheoTinh*100 As TyLeHocSinhTrungHoc, SinhVien/DanSoTheoTinh*100 As TyLeSinhVien
From Student

-- 4) Creating View to visualize data
	-- Bảng 1: Tỷ lệ nam/nữ tại từng tỉnh
Create View Table_TyLeNamNuTheoTinh as
Select Tinh, 
SUM(Nam) As SoNam, 
SUM(Nu) As SoNu, 
SUM(DanSo) As DanSoTheoTinh, 
SUM(Nam)/SUM(DanSo)*100 As TyLeNam, 
SUM(Nu)/SUM(DanSo)*100 As TyLeNu
From PortfolioProjects..Demographic10provinces 
Where Tinh is not null
Group By Tinh

	-- Bảng 2: Tỷ lệ nam/nữ và tỷ lệ dân số tại từng huyện (So Sánh giữa các huyện trong 1 tỉnh)
Create View Table_TyLeNamNuTheoHuyen as
With Gender As
(
Select Tinh, Huyen,
SoNam, SUM(SoNam) OVER (PARTITION BY Tinh) As SoNamToanTinh, 
SoNu, SUM(SoNu) OVER (PARTITION BY Tinh) As SoNuToanTinh, 
DanSoTheoHuyen, SUM(DanSoTheoHuyen) OVER (PARTITION BY Tinh) As DanSoTheoTinh
From Gender_Huyen 
)
Select *,
SoNam/SoNamToanTinh*100 As TyLeNam,
SoNu/SoNuToanTinh*100 As TyLeNu,
DanSoTheoHuyen/DanSoTheoTinh*100 As TyleDanSo
From Gender

	-- Bảng 3: Thống kê tỷ lệ dân số theo nhóm tuổi ở từng tỉnh
Create View Table_Age As
With Age As 
(
Select Tinh, Huyen, Xa, 
DanSo, 
NuDuoi15t + NamDuoi15t As Duoi15t, 
Nu_15_60t + Nam_15_60t As Tu15_60t, 
NuTren60t + NamTren60t As Tren60t
From PortfolioProjects..Demographic10provinces 
Where Tinh is not null
)
Select Tinh, 
SUM(DanSo) As DanSoTheoTinh, SUM(Duoi15t) As Duoi15t, SUM(Tu15_60t) As Tu15_60t, SUM(Tren60t) As Tren60t, 
SUM(Duoi15t)/SUM(DanSo)*100 As TyLeDuoi15t, SUM(Tu15_60t)/SUM(DanSo)*100 As TyLeTu15_60t, SUM(Tren60t)/SUM(DanSo)*100 As TyLeTren60t
From Age
Group By Tinh

	-- Bảng 4: Tỷ lệ học sinh trung học và sinh viên tại từng tỉnh
Create View Table_Student As
With Student As
(
Select Tinh, DanSoTheoTinh, THCS + THPT As HsTrungHoc, CaoDang + DaiHoc As SinhVien
From Education
)
Select *, HsTrungHoc/DanSoTheoTinh*100 As TyLeHocSinhTrungHoc, SinhVien/DanSoTheoTinh*100 As TyLeSinhVien
From Student
