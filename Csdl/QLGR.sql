/*CREATE DATABASE QLGR
go*/

use master
go

create database QLGR
go

USE QLGR
GO
/****** Object:  StoredProcedure [dbo].[CAPNHATCT_BCDT]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 11/11/2021
-- Description:	Cập nhật số lượt sửa của chi tiết báo cáo doanh thu
-- =============================================
CREATE PROCEDURE [dbo].[CAPNHATCT_BCDT] 
	-- Add the parameters for the stored procedure here
	@MABC CHAR(20),
	@MACTBC CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @SOLUOTSUA INT

	SET @SOLUOTSUA = (SELECT SOLUOTSUA FROM CT_BCDT WHERE MABC = @MABC AND MACTBC = @MACTBC) + 1

	UPDATE CT_BCDT SET SOLUOTSUA = @SOLUOTSUA WHERE MABC = @MABC AND MACTBC = @MACTBC

END

GO
/****** Object:  StoredProcedure [dbo].[CAPNHATDOANHTHU]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 11/11/2021
-- Description:	Cập nhật doanh thu báo cáo tháng, cập nhật thành tiền và tỉ lệ của hiệu xe
-- =============================================
CREATE PROCEDURE [dbo].[CAPNHATDOANHTHU] 
	-- Add the parameters for the stored procedure here
	@MABC CHAR(20),
	@MACTBC CHAR(20),
	@SOTIEN MONEY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @DOANHSO MONEY
	DECLARE @THANHTIEN MONEY
	DECLARE @TILE FLOAT

	SET @DOANHSO = (SELECT TONGDOANHTHU FROM BAOCAODOANHTHU WHERE MABCDT = @MABC) + @SOTIEN
	SET @THANHTIEN = (SELECT THANHTIEN FROM CT_BCDT WHERE MACTBC = @MACTBC AND MABC = @MABC) + @SOTIEN
	SET @TILE = @THANHTIEN / @DOANHSO 

	UPDATE BAOCAODOANHTHU SET TONGDOANHTHU = @DOANHSO WHERE MABCDT = @MABC
	UPDATE CT_BCDT SET THANHTIEN = @THANHTIEN, TILE = @TILE WHERE MACTBC = @MACTBC AND MABC = @MABC

END

GO
/****** Object:  StoredProcedure [dbo].[CAPNHATPHATSINH]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Cập nhật phát sinh
-- =============================================
CREATE PROCEDURE [dbo].[CAPNHATPHATSINH] 
	-- Add the parameters for the stored procedure here
	@MACTBCT CHAR(20),
	@SL INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF(EXISTS(SELECT MACTBCT FROM CT_BCT WHERE MACTBCT = @MACTBCT))
	BEGIN
		declare @PHATSINH int, @TONCUOI INT
		set @PHATSINH = (select PHATSINH from CT_BCT where MACTBCT = @MACTBCT)
		set @PHATSINH = @PHATSINH + @SL
		SET @TONCUOI = (SELECT TONCUOI FROM CT_BCT WHERE MACTBCT = @MACTBCT)
		SET @TONCUOI = @TONCUOI + @SL
		UPDATE CT_BCT SET PHATSINH = @PHATSINH, TONCUOI = @TONCUOI WHERE  MACTBCT = @MACTBCT
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END	
END

GO
/****** Object:  StoredProcedure [dbo].[CAPNHATTILE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Cập nhật lại tỉ lệ của hiệu xe trong chi tiết báo cáo doanh thu
-- =============================================
CREATE PROCEDURE [dbo].[CAPNHATTILE] 
	-- Add the parameters for the stored procedure here
	@MACTBC CHAR(20),
	@MABC CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @THANHTIEN MONEY
	DECLARE @TONGDOANHTHU MONEY
	DECLARE @TILE FLOAT

	SET @THANHTIEN = (SELECT THANHTIEN FROM CT_BCDT WHERE MACTBC = @MACTBC AND MABC = @MABC)
	SET @TONGDOANHTHU = (SELECT TONGDOANHTHU FROM BAOCAODOANHTHU WHERE MABCDT = @MABC)
	SET @TILE =  @THANHTIEN / @TONGDOANHTHU

	UPDATE CT_BCDT SET TILE = @TILE WHERE MACTBC = @MACTBC AND MABC = @MABC
END

GO
/****** Object:  StoredProcedure [dbo].[CAPNHATTONCUOI]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Cập nhật tồn cuối
-- =============================================
CREATE PROCEDURE [dbo].[CAPNHATTONCUOI] 
	-- Add the parameters for the stored procedure here
	@MACTBCT CHAR(20),
	@SL INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MACTBCT FROM CT_BCT WHERE MACTBCT = @MACTBCT))
	BEGIN
		DECLARE @TONCUOI INT
		SET @TONCUOI = (SELECT TONCUOI FROM CT_BCT WHERE MACTBCT = @MACTBCT )
		SET @TONCUOI = @TONCUOI - @SL
		UPDATE CT_BCT SET TONCUOI = @TONCUOI WHERE  MACTBCT = @MACTBCT
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[CAPNHATTONGTIEN]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Cập nhật tổng tiền
-- =============================================
CREATE PROCEDURE [dbo].[CAPNHATTONGTIEN] 
	-- Add the parameters for the stored procedure here
	@_MAPSC CHAR(25),
	@_TONGTIEN MONEY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MAPSC FROM PHIEUSUACHUA WHERE MAPSC = @_MAPSC))
	BEGIN
		DECLARE @BIENSO CHAR(10)
		SET @BIENSO = (SELECT BIENSO FROM PHIEUSUACHUA WHERE MAPSC = @_MAPSC)
		UPDATE PHIEUSUACHUA SET TONGTIEN = @_TONGTIEN WHERE MAPSC = @_MAPSC
		UPDATE XE SET TIENNO = @_TONGTIEN WHERE BIENSO = @BIENSO
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[GETBAOCAODOANHSO]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy báo cáo doanh số theo tháng
-- =============================================
CREATE PROCEDURE [dbo].[GETBAOCAODOANHSO] 
	-- Add the parameters for the stored procedure here
	@THANG INT,
	@NAM INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MABCDT FROM BAOCAODOANHTHU WHERE THANG = @THANG AND NAM = @NAM
END

GO
/****** Object:  StoredProcedure [dbo].[GETCT_BAOCAODOANHTHU]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy mã chi tiết báo cáo doanh thu
-- =============================================
CREATE PROCEDURE [dbo].[GETCT_BAOCAODOANHTHU] 
	-- Add the parameters for the stored procedure here
	@MABC CHAR(20),
	@HIEUXE VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MACTBC FROM CT_BCDT WHERE MABC = @MABC AND HIEUXE = @HIEUXE
END

GO
/****** Object:  StoredProcedure [dbo].[GETDONGIAPHUTUNG]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy tiền của phụ tùng tương ứng
-- =============================================
CREATE PROCEDURE [dbo].[GETDONGIAPHUTUNG] 
	-- Add the parameters for the stored procedure here
	@MAPT CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MAPT FROM PHUTUNG WHERE MAPT = @MAPT))
	BEGIN
		SELECT DONGIA FROM PHUTUNG WHERE MAPT = @MAPT
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[GETHIEUXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy hiệu xe của một xe
-- =============================================
CREATE PROCEDURE [dbo].[GETHIEUXE] 
	-- Add the parameters for the stored procedure here
	@BIENSO CHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT HIEUXE FROM XE WHERE BIENSO = @BIENSO
END

GO
/****** Object:  StoredProcedure [dbo].[GETLISTCHITIETSUACHUA]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy danh sách các chi tiết phiếu sửa chửa
-- =============================================
CREATE PROCEDURE [dbo].[GETLISTCHITIETSUACHUA] 
	-- Add the parameters for the stored procedure here
	@MAPSC CHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MAPSC FROM PHIEUSUACHUA WHERE MAPSC = @MAPSC))
	BEGIN
		SELECT * FROM CT_PSC WHERE MAPSC = @MAPSC
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[GETLISTCT_PSC]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy tất cả các chi tiết phiếu sửa chữa
-- =============================================
CREATE PROCEDURE [dbo].[GETLISTCT_PSC] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM CT_PSC
END

GO
/****** Object:  StoredProcedure [dbo].[GETLISTHIEUXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy danh sách các hiệu xe
-- =============================================
CREATE PROCEDURE [dbo].[GETLISTHIEUXE] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM HIEUXE
END

GO
/****** Object:  StoredProcedure [dbo].[GETLISTPHUTUNG]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 23/4/23016
-- Description:	Lấy danh sách các phụ tùng
-- =============================================
CREATE PROCEDURE [dbo].[GETLISTPHUTUNG] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *FROM PHUTUNG
END

GO
/****** Object:  StoredProcedure [dbo].[GETLISTTIENCONG]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy danh sách các loại tiền công
-- =============================================
CREATE PROCEDURE [dbo].[GETLISTTIENCONG] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *FROM TIENCONG
END

GO
/****** Object:  StoredProcedure [dbo].[GETLISTXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy danh sách các xe có trong gara
-- =============================================
CREATE PROCEDURE [dbo].[GETLISTXE] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT *FROM XE
END

GO
/****** Object:  StoredProcedure [dbo].[GETMABAOCAOTON]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy mã báo cáo tồn vật tư phụ tùng
-- =============================================
CREATE PROCEDURE [dbo].[GETMABAOCAOTON] 
	-- Add the parameters for the stored procedure here
	@THANG INT,
	@NAM INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MABCT FROM BAOCAOTON WHERE THANG = @THANG AND NAM = @NAM
END

GO
/****** Object:  StoredProcedure [dbo].[GETMACTBCT]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy mã chi tiết báo cáo tồn
-- =============================================
CREATE PROCEDURE [dbo].[GETMACTBCT] 
	-- Add the parameters for the stored procedure here
	@MABCT CHAR(20),
	@TENPT NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MACTBCT FROM CT_BCT WHERE MABC = @MABCT AND TENPT = @TENPT
END

GO
/****** Object:  StoredProcedure [dbo].[GETMAPTTUCTSC]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 23/4/216
-- Description:	Lấy mã phụ tùng trong chi tiết phiếu sửa chữa
-- =============================================
CREATE PROCEDURE [dbo].[GETMAPTTUCTSC] 
	-- Add the parameters for the stored procedure here
	@MACT CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MAPT FROM CT_PSC WHERE MACTSC = @MACT
END

GO
/****** Object:  StoredProcedure [dbo].[GETMATKHAU]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy mật khẩu
-- =============================================
CREATE PROCEDURE [dbo].[GETMATKHAU] 
	-- Add the parameters for the stored procedure here
	@TENDANGNHAP CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MATKHAU FROM TAIKHOAN WHERE TENDANGNHAP  = @TENDANGNHAP
END

GO
/****** Object:  StoredProcedure [dbo].[GETNOIDUNGTUCTSC]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy nội dung trong chi tiết phiếu sửa chữa
-- =============================================
CREATE PROCEDURE [dbo].[GETNOIDUNGTUCTSC] 
	-- Add the parameters for the stored procedure here
	@MACT CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT NOIDUNG FROM CT_PSC WHERE MACTSC = @MACT
END

GO
/****** Object:  StoredProcedure [dbo].[GETPSC]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy tất cả các phiếu sửa chữa của xe
-- =============================================
CREATE PROCEDURE [dbo].[GETPSC] 
	-- Add the parameters for the stored procedure here
	@BIENSO CHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MAPSC FROM PHIEUSUACHUA WHERE BIENSO = @BIENSO
END

GO
/****** Object:  StoredProcedure [dbo].[GETPTT]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy phiếu thu tiền của xe
-- =============================================
CREATE PROCEDURE [dbo].[GETPTT] 
	-- Add the parameters for the stored procedure here
	@BIENSO CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM PHIEUTHUTIEN WHERE BIENSO = @BIENSO
END

GO
/****** Object:  StoredProcedure [dbo].[GETSLPHUTUNG]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy số lượng phụ tùng
-- =============================================
CREATE PROCEDURE [dbo].[GETSLPHUTUNG] 
	-- Add the parameters for the stored procedure here
	@TENPT NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT SL FROM PHUTUNG WHERE TENPT = @TENPT
END

GO
/****** Object:  StoredProcedure [dbo].[GETSOXESUACHUATOIDA]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy số xe sửa chữa tối đa trong ngày
-- =============================================
CREATE PROCEDURE [dbo].[GETSOXESUACHUATOIDA] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM QUYDINH
END

GO
/****** Object:  StoredProcedure [dbo].[GETTAIKHOAN]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy tất cả các tài khoản
-- =============================================
CREATE PROCEDURE [dbo].[GETTAIKHOAN] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM TAIKHOAN
END

GO
/****** Object:  StoredProcedure [dbo].[GETTENCHUXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy tên chủ xe theo biển số
-- =============================================
CREATE PROCEDURE [dbo].[GETTENCHUXE] 
	-- Add the parameters for the stored procedure here
	@BIENSO CHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT BIENSO FROM XE WHERE BIENSO = @BIENSO))
	BEGIN
		SELECT TENCHUXE FROM XE WHERE BIENSO = @BIENSO 
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[GETTHONGTINUSER]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy thông tin người dùng
-- =============================================
CREATE PROCEDURE [dbo].[GETTHONGTINUSER] 
	-- Add the parameters for the stored procedure here
	@TENDANGNHAP CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM TAIKHOAN WHERE TENDANGNHAP = @TENDANGNHAP
END

GO
/****** Object:  StoredProcedure [dbo].[GETTHONGTINXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy thông tin xe theo biển số
-- =============================================
CREATE PROCEDURE [dbo].[GETTHONGTINXE] 
	-- Add the parameters for the stored procedure here
	@BIENSO CHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT BIENSO FROM XE WHERE BIENSO = @BIENSO))
	BEGIN
		SELECT * FROM XE WHERE BIENSO = @BIENSO
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[GETTIENCONG]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy tiền công tương ứng với nội dung
-- =============================================
CREATE PROCEDURE [dbo].[GETTIENCONG] 
	-- Add the parameters for the stored procedure here
	@NOIDUNG NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT NOIDUNG FROM TIENCONG WHERE NOIDUNG = @NOIDUNG))
	BEGIN
		SELECT TIENCONG FROM TIENCONG WHERE NOIDUNG = @NOIDUNG
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[LAYDULIEUTAIKHOAN]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy dữ liệu tài khoản
-- =============================================
CREATE PROCEDURE [dbo].[LAYDULIEUTAIKHOAN] 
	-- Add the parameters for the stored procedure here
	@TENDANGNHAP CHAR(20),
	@MATKHAU CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM TAIKHOAN WHERE TENDANGNHAP = @TENDANGNHAP AND MATKHAU = @MATKHAU
END

GO
/****** Object:  StoredProcedure [dbo].[LAYQUYENTAIKHOAN]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Lấy quyền của tài khoản
-- =============================================
CREATE PROCEDURE [dbo].[LAYQUYENTAIKHOAN] 
	-- Add the parameters for the stored procedure here
	@TENDANGNHAP CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT QUYEN FROM TAIKHOAN WHERE TENDANGNHAP = @TENDANGNHAP
END

GO
/****** Object:  StoredProcedure [dbo].[LAYSOXETIEPNHANTRONGNGAY]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[LAYSOXETIEPNHANTRONGNGAY] 
	-- Add the parameters for the stored procedure here
	@NGAYTIEPNHAN SMALLDATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT COUNT(BIENSO) FROM XE WHERE NGAYTIEPNHAN = @NGAYTIEPNHAN
END

GO
/****** Object:  StoredProcedure [dbo].[SUATTXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 19/4/2016
-- Description:	Sửa thông tin xe
-- =============================================
CREATE PROCEDURE [dbo].[SUATTXE] 
	-- Add the parameters for the stored procedure here
	@BIENSO CHAR(10),
	@TENCX NVARCHAR(50),
	@DIACHI NVARCHAR(100),
	@DIENTHOAI VARCHAR(15),
	@EMAIL VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT BIENSO FROM XE WHERE BIENSO = @BIENSO))
	BEGIN
		UPDATE XE SET TENCHUXE = @TENCX, DIACHI = @DIACHI, DIENTHOAI = @DIENTHOAI, EMAIL = @EMAIL WHERE BIENSO = @BIENSO
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[TDSLXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 19/4/2016
-- Description:	Thay đổi số xe sửa chữa tối đa trong ngày
-- =============================================
CREATE PROCEDURE [dbo].[TDSLXE] 
	-- Add the parameters for the stored procedure here
	@SOXESUACHUATOIDA INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE QUYDINH
	INSERT INTO QUYDINH(SOXESUACHUATOIDA) VALUES (@SOXESUACHUATOIDA)
END

GO
/****** Object:  StoredProcedure [dbo].[THAYDOIDONGIAPT]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thay đổi đơn giá phụ tùng
-- =============================================
CREATE PROCEDURE [dbo].[THAYDOIDONGIAPT] 
	-- Add the parameters for the stored procedure here
	@MAPT CHAR(20),
	@DONGIA MONEY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MAPT FROM PHUTUNG WHERE MAPT = @MAPT))
	BEGIN
		UPDATE PHUTUNG SET DONGIA = @DONGIA WHERE MAPT = @MAPT
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THAYDOIMATKHAU]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thay đổi mật khẩu người dùng
-- =============================================
CREATE PROCEDURE [dbo].[THAYDOIMATKHAU] 
	-- Add the parameters for the stored procedure here
	@TENDANGNHAP CHAR(20),
	@MATKHAU CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT TENDANGNHAP FROM TAIKHOAN WHERE TENDANGNHAP = @TENDANGNHAP))
	BEGIN
		UPDATE TAIKHOAN SET MATKHAU = @MATKHAU WHERE TENDANGNHAP = @TENDANGNHAP
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THAYDOISLPT]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thay đổi số lượng phụ tùng
-- =============================================
CREATE PROCEDURE [dbo].[THAYDOISLPT] 
	-- Add the parameters for the stored procedure here
	@MAPT CHAR(20),
	@SL INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MAPT FROM PHUTUNG WHERE MAPT = @MAPT))
	BEGIN
		UPDATE PHUTUNG SET SL = @SL WHERE MAPT = @MAPT
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THAYDOITAIKHOAN]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thay đổi thông tin tài khoản
-- =============================================
CREATE PROCEDURE [dbo].[THAYDOITAIKHOAN] 
	-- Add the parameters for the stored procedure here
	@TENDANGNHAP CHAR(20),
	@QUYEN CHAR(10),
	@HOTEN NVARCHAR(50),
	@SODT CHAR(11),
	@DIACHI NVARCHAR(50),
	@EMAIL CHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE TAIKHOAN SET QUYEN = @QUYEN, HOTEN = @HOTEN, SDT = @SODT, DIACHI = @DIACHI, EMAIL = @EMAIL WHERE TENDANGNHAP = @TENDANGNHAP
END

GO
/****** Object:  StoredProcedure [dbo].[THAYDOITIENCONG]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thay đổi tiền công
-- =============================================
CREATE PROCEDURE [dbo].[THAYDOITIENCONG] 
	-- Add the parameters for the stored procedure here
	@NOIDUNG NVARCHAR(100), 
	@TIENCONG MONEY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT NOIDUNG FROM TIENCONG WHERE NOIDUNG = @NOIDUNG))
	BEGIN
		UPDATE TIENCONG SET TIENCONG = @TIENCONG WHERE NOIDUNG = @NOIDUNG
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THAYDOITIENNO]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 19/4/2016
-- Description:	Thay đổi tiền nợ
-- =============================================
CREATE PROCEDURE [dbo].[THAYDOITIENNO] 
	-- Add the parameters for the stored procedure here
	@_BIENSO CHAR(10),
	@_TIENNO MONEY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT BIENSO FROM XE WHERE BIENSO = @_BIENSO))
	BEGIN
		UPDATE XE SET TIENNO = @_TIENNO WHERE BIENSO = @_BIENSO
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THAYDOIVTPT]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thay đổi vật tư phụ tùng
-- =============================================
CREATE PROCEDURE [dbo].[THAYDOIVTPT] 
	-- Add the parameters for the stored procedure here
	@MAPT CHAR(20),
	@DONGIA MONEY,
	@TENPT NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MAPT FROM PHUTUNG WHERE MAPT = @MAPT))
	BEGIN
		UPDATE PHUTUNG SET DONGIA = @DONGIA, TENPT = @TENPT WHERE MAPT = @MAPT
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THEMBAOCAOTON]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thêm báo cáo tồn
-- =============================================
CREATE PROCEDURE [dbo].[THEMBAOCAOTON] 
	-- Add the parameters for the stored procedure here
	@MABCT CHAR(20),
	@THANG INT,
	@NAM INT
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF(EXISTS(SELECT MABCT FROM BAOCAOTON WHERE MABCT = @MABCT))
	BEGIN
		SELECT ERROR = 1
	END
	ELSE
	BEGIN
		INSERT INTO BAOCAOTON VALUES(@MABCT,@THANG,@NAM)
		SELECT ERROR = 0
	END 
END

GO
/****** Object:  StoredProcedure [dbo].[THEMBCDS]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thêm báo cáo doanh số
-- =============================================
CREATE PROCEDURE [dbo].[THEMBCDS] 
	-- Add the parameters for the stored procedure here
	@MABC CHAR(20),
	@THANG INT,
	@NAM INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MABCDT FROM BAOCAODOANHTHU WHERE MABCDT = @MABC))
	BEGIN
		SELECT ERROR = 1
	END
	ELSE 
	BEGIN
		INSERT INTO BAOCAODOANHTHU (MABCDT, THANG, NAM, TONGDOANHTHU) VALUES (@MABC, @THANG, @NAM, 0)
		SELECT ERROR = 0
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THEMCT_BCDT]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thêm chi tiết báo cáo doanh thu
-- =============================================
CREATE PROCEDURE [dbo].[THEMCT_BCDT] 
	-- Add the parameters for the stored procedure here
	@MACTBC CHAR(20),
	@MABC CHAR(20),
	@HIEUXE VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MABCDT FROM BAOCAODOANHTHU WHERE MABCDT = @MABC))
	BEGIN
		INSERT INTO CT_BCDT(MACTBC, MABC, HIEUXE, SOLUOTSUA, THANHTIEN, TILE) VALUES (@MACTBC, @MABC, @HIEUXE, 0, 0, 0)
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THEMCT_BCT]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thêm chi tiết báo cáo tồn
-- =============================================
CREATE PROCEDURE [dbo].[THEMCT_BCT] 
	-- Add the parameters for the stored procedure here
	@MACTBCT CHAR(20),
	@MABC CHAR(20),
	@TENPT NVARCHAR(50),
	@TONDAU INT,
	@PHATSINH INT,
	@TONCUOI INT
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF(EXISTS(SELECT MACTBCT FROM CT_BCT WHERE MACTBCT = @MACTBCT))
	BEGIN
		SELECT ERROR = 1
	END
	ELSE
	BEGIN
		INSERT INTO CT_BCT VALUES(@MACTBCT,@MABC,@TENPT,@TONDAU,@PHATSINH,@TONCUOI)
		SELECT ERROR = 0
	END 
END

GO
/****** Object:  StoredProcedure [dbo].[THEMCT_PSC]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thêm chi tiết phiếu sửa chữa
-- =============================================
CREATE PROCEDURE [dbo].[THEMCT_PSC] 
	-- Add the parameters for the stored procedure here
	@MACTPSC CHAR(25),
	@MAPSC CHAR(25),
	@NOIDUNG NVARCHAR(100),
	@MAPT CHAR(20),
	@SL INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MACTSC FROM CT_PSC WHERE MACTSC = @MACTPSC))
	BEGIN
		SELECT ERROR = 1
	END
	ELSE 
	BEGIN
		DECLARE @THANHTIEN MONEY
		DECLARE @TONGTIEN MONEY
		DECLARE @TIENCONG MONEY
		DECLARE @DONGIA MONEY
		DECLARE @SLCONLAI INT

		SET @TONGTIEN = (SELECT TONGTIEN FROM PHIEUSUACHUA WHERE MAPSC = @MAPSC)
		SET @TIENCONG = (SELECT TIENCONG FROM TIENCONG WHERE NOIDUNG = @NOIDUNG)
		SET @DONGIA = (SELECT DONGIA FROM PHUTUNG WHERE MAPT = @MAPT)
		SET @THANHTIEN = @SL * @DONGIA + @TIENCONG
		SET @SLCONLAI = (SELECT SL FROM PHUTUNG WHERE MAPT = @MAPT) - @SL

		SET @TONGTIEN = @TONGTIEN + @THANHTIEN

		INSERT INTO CT_PSC(MACTSC, MAPSC, MAPT, SL, NOIDUNG, THANHTIEN) VALUES (@MACTPSC, @MAPSC, @MAPT, @SL, @NOIDUNG, @THANHTIEN)
		EXEC CAPNHATTONGTIEN @_MAPSC = @MAPSC, @_TONGTIEN = @TONGTIEN
		UPDATE PHUTUNG SET SL = @SLCONLAI WHERE MAPT = @MAPT

		SELECT ERROR = 0
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THEMHIEUXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 19/1/2016
-- Description:	Thêm hiệu xe
-- =============================================
CREATE PROCEDURE [dbo].[THEMHIEUXE] 
	-- Add the parameters for the stored procedure here
	@HIEUXE VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT HIEUXE FROM HIEUXE WHERE HIEUXE = @HIEUXE))
	BEGIN
		SELECT ERROR = 1
	END
	ELSE
	BEGIN
		INSERT INTO HIEUXE(HIEUXE) VALUES (@HIEUXE)
		SELECT ERROR = 0
	END
	
END

GO
/****** Object:  StoredProcedure [dbo].[THEMPHIEUTHUTIEN]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thêm phiếu thu tiền
-- =============================================
CREATE PROCEDURE [dbo].[THEMPHIEUTHUTIEN] 
	-- Add the parameters for the stored procedure here
	@MAPHIEU CHAR(20),
	@BIENSO CHAR(10),
	@NGAYTHU SMALLDATETIME,
	@SOTIENTHU MONEY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MAPTT FROM PHIEUTHUTIEN WHERE MAPTT = @MAPHIEU))
	BEGIN
		SELECT ERROR = 1
	END
	ELSE
	BEGIN
		INSERT INTO PHIEUTHUTIEN(MAPTT, BIENSO, NGAYTHU, SOTIENTHU) VALUES (@MAPHIEU, @BIENSO, @NGAYTHU, @SOTIENTHU)
		SELECT ERROR = 0
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THEMPHUTUNG]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thêm phụ tùng
-- =============================================
CREATE PROCEDURE [dbo].[THEMPHUTUNG] 
	-- Add the parameters for the stored procedure here
	@MAPT CHAR(20),
	@TENPT NVARCHAR(50),
	@SL INT,
	@DONGIA MONEY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MAPT FROM PHUTUNG WHERE MAPT = @MAPT))
	BEGIN
		SELECT ERROR = 1
	END
	ELSE
	BEGIN
		INSERT INTO PHUTUNG(MAPT, TENPT, SL, DONGIA) VALUES (@MAPT, @TENPT, @SL, @DONGIA)
		SELECT ERROR = 0
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THEMPSC]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 23/4/20116
-- Description:	Thêm phiếu sửa chữa
-- =============================================
CREATE PROCEDURE [dbo].[THEMPSC] 
	-- Add the parameters for the stored procedure here
	@MAPSC CHAR(25),
	@BIENSO CHAR(10),
	@NGAYSC SMALLDATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MAPSC FROM PHIEUSUACHUA WHERE MAPSC = @MAPSC))
	BEGIN
		SELECT ERROR = 1
	END
	ELSE 
	BEGIN
		INSERT INTO PHIEUSUACHUA(MAPSC, BIENSO, NGAYSUACHUA, TONGTIEN) VALUES (@MAPSC, @BIENSO, @NGAYSC, 0)
		SELECT ERROR = 0
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THEMTAIKHOAN]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thêm một tài khoản mới
-- =============================================
CREATE PROCEDURE [dbo].[THEMTAIKHOAN] 
	-- Add the parameters for the stored procedure here
	@TENDANGNHAP CHAR(20),
	@MATKHAU CHAR(20),
	@QUYEN CHAR(10),
	@HOTEN NVARCHAR(50),
	@SODT CHAR(11),
	@DIACHI NVARCHAR(50),
	@EMAIL CHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT TENDANGNHAP FROM TAIKHOAN WHERE TENDANGNHAP = @TENDANGNHAP))
	BEGIN
		SELECT ERROR = 1
	END
	ELSE
	BEGIN
		INSERT INTO TAIKHOAN(TENDANGNHAP, MATKHAU, QUYEN, HOTEN, EMAIL, SDT, DIACHI) VALUES (@TENDANGNHAP, @MATKHAU, @QUYEN, @HOTEN, @EMAIL, @SODT, @DIACHI)
		SELECT ERROR = 0
	END
END

GO
/****** Object:  StoredProcedure [dbo].[THEMTIENCONG]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Thêm tiền công
-- =============================================
CREATE PROCEDURE [dbo].[THEMTIENCONG] 
	-- Add the parameters for the stored procedure here
	@NOIDUNG NVARCHAR(100),
	@TIENCONG MONEY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT NOIDUNG FROM TIENCONG WHERE NOIDUNG = @NOIDUNG))
	BEGIN
		SELECT ERROR = 1
	END
	ELSE
	BEGIN
		INSERT INTO TIENCONG(NOIDUNG, TIENCONG) VALUES (@NOIDUNG, @TIENCONG)
		SELECT ERROR = 0 
	END
END
GO
/****** Object:  StoredProcedure [dbo].[THEMXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 15/4/2014
-- Description:	Thêm Xe
-- =============================================
CREATE PROCEDURE [dbo].[THEMXE] 
	-- Add the parameters for the stored procedure here
	@BIENSO CHAR(10),
	@TENCX NVARCHAR(50),
	@HIEUXE VARCHAR(20),
	@DIACHI NVARCHAR(100),
	@DIENTHOAI VARCHAR(15),
	@EMAIL VARCHAR(50),
	@NGAYTN SMALLDATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT BIENSO FROM XE WHERE BIENSO = @BIENSO))
	BEGIN
		SELECT ERROR = 1
	END
	ELSE
	BEGIN
		INSERT INTO XE (BIENSO, HIEUXE, TENCHUXE, DIACHI, DIENTHOAI, EMAIL, NGAYTIEPNHAN, TIENNO) VALUES (@BIENSO, @HIEUXE, @TENCX, @DIACHI, @DIENTHOAI, @EMAIL, @NGAYTN, 0)
		SELECT ERROR = 0
	END
END

GO
/****** Object:  StoredProcedure [dbo].[TIMKIEMXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 3/7/2016
-- Description:	Tìm kiếm xe
-- =============================================
CREATE PROCEDURE [dbo].[TIMKIEMXE] 
	-- Add the parameters for the stored procedure here
	@TUKHOA NVARCHAR(50) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM XE WHERE BIENSO LIKE '%' + @TUKHOA + '%' OR HIEUXE LIKE '%' + @TUKHOA +'%' OR TENCHUXE LIKE '%' + @TUKHOA + '%'
END

GO
/****** Object:  StoredProcedure [dbo].[XOACHITIETPSC]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Xóa chi tiết phiếu sửa chữa
-- =============================================
CREATE PROCEDURE [dbo].[XOACHITIETPSC] 
	-- Add the parameters for the stored procedure here
	@MACT CHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MAPSC CHAR(25)
	DECLARE @THANHTIEN MONEY
	DECLARE @TONGTIEN MONEY
	DECLARE @MAPT CHAR(20)
	DECLARE @SLXAI INT
	DECLARE @SL INT

	SET @MAPSC = (SELECT MAPSC FROM CT_PSC WHERE MACTSC = @MACT)
	SET @THANHTIEN = (SELECT THANHTIEN FROM CT_PSC WHERE MACTSC = @MACT)
	SET @TONGTIEN = (SELECT TONGTIEN FROM PHIEUSUACHUA WHERE MAPSC = @MAPSC) - @THANHTIEN

	SET @MAPT = (SELECT MAPT FROM CT_PSC WHERE MACTSC = @MACT)
	SET @SLXAI = (SELECT SL FROM CT_PSC WHERE MACTSC = @MACT)
	SET @SL = (SELECT SL FROM PHUTUNG WHERE MAPT = @MAPT) + @SLXAI
	

    -- Insert statements for procedure here
	DELETE FROM CT_PSC WHERE MACTSC = @MACT
	UPDATE PHIEUSUACHUA SET TONGTIEN = @TONGTIEN WHERE MAPSC = @MAPSC
	UPDATE PHUTUNG SET SL = @SL WHERE MAPT = @MAPT
END

GO
/****** Object:  StoredProcedure [dbo].[XOAHIEUXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 3/7/2016
-- Description:	Thêm hiệu xe
-- =============================================
CREATE PROCEDURE [dbo].[XOAHIEUXE] 
	-- Add the parameters for the stored procedure here
	@HIEUXE VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM HIEUXE WHERE HIEUXE = @HIEUXE
END

GO
/****** Object:  StoredProcedure [dbo].[XOAPHIEUSUACHUA]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Xóa phiếu sửa chữa
-- =============================================
CREATE PROCEDURE [dbo].[XOAPHIEUSUACHUA] 
	-- Add the parameters for the stored procedure here
	@MAPSC CHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MAPSC FROM PHIEUSUACHUA WHERE MAPSC = @MAPSC))
	BEGIN
		DELETE FROM CT_PSC WHERE MAPSC = @MAPSC
		DELETE FROM PHIEUSUACHUA WHERE MAPSC = @MAPSC
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[XOAPHIEUTHUTIEN]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Xóa phiếu thu tiền
-- =============================================
CREATE PROCEDURE [dbo].[XOAPHIEUTHUTIEN] 
	-- Add the parameters for the stored procedure here
	@MAPTT CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MAPTT FROM PHIEUTHUTIEN WHERE MAPTT = @MAPTT))
	BEGIN
		DELETE FROM PHIEUTHUTIEN WHERE MAPTT = @MAPTT
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[XOAPHUTUNG]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Xóa phụ tùng
-- =============================================
CREATE PROCEDURE [dbo].[XOAPHUTUNG] 
	-- Add the parameters for the stored procedure here
	@MAPT CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT MAPT FROM PHUTUNG WHERE MAPT = @MAPT))
	BEGIN
		DELETE FROM PHUTUNG WHERE MAPT = @MAPT
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[XOATAIKHOAN]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 2//7/2016
-- Description:	Xóa tài khoản
-- =============================================
CREATE PROCEDURE [dbo].[XOATAIKHOAN] 
	-- Add the parameters for the stored procedure here
	@TENDANGNHAP CHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM TAIKHOAN WHERE TENDANGNHAP = @TENDANGNHAP
END

GO
/****** Object:  StoredProcedure [dbo].[XOATIENCONG]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Xóa tiền công
-- =============================================
CREATE PROCEDURE [dbo].[XOATIENCONG] 
	-- Add the parameters for the stored procedure here
	@NOIDUNG NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT NOIDUNG FROM TIENCONG WHERE NOIDUNG = @NOIDUNG))
	BEGIN
		DELETE FROM TIENCONG WHERE NOIDUNG = @NOIDUNG
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  StoredProcedure [dbo].[XOAXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		 
-- Create date: 11/11/2021
-- Description:	Xóa xe
-- =============================================
CREATE PROCEDURE [dbo].[XOAXE] 
	-- Add the parameters for the stored procedure here
	@BIENSO CHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(EXISTS(SELECT BIENSO FROM XE WHERE BIENSO = @BIENSO))
	BEGIN
		DELETE FROM XE WHERE BIENSO = @BIENSO
		SELECT ERROR = 0
	END
	ELSE
	BEGIN
		SELECT ERROR = 1
	END
END

GO
/****** Object:  Table [dbo].[BAOCAODOANHTHU]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BAOCAODOANHTHU](
	[MABCDT] [char](20) NOT NULL,
	[THANG] [int] NULL,
	[NAM] [int] NULL,
	[TONGDOANHTHU] [money] NULL,
 CONSTRAINT [BCDT_PK] PRIMARY KEY CLUSTERED 
(
	[MABCDT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BAOCAOTON]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BAOCAOTON](
	[MABCT] [char](20) NOT NULL,
	[THANG] [int] NULL,
	[NAM] [int] NULL,
 CONSTRAINT [PK_BAOCAOTON] PRIMARY KEY CLUSTERED 
(
	[MABCT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CT_BCDT]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CT_BCDT](
	[MACTBC] [char](20) NOT NULL,
	[MABC] [char](20) NOT NULL,
	[HIEUXE] [varchar](20) NULL,
	[SOLUOTSUA] [int] NULL,
	[THANHTIEN] [money] NULL,
	[TILE] [float] NULL,
 CONSTRAINT [CTBCDT_PK] PRIMARY KEY CLUSTERED 
(
	[MACTBC] ASC,
	[MABC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CT_BCT]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CT_BCT](
	[MACTBCT] [char](20) NOT NULL,
	[MABC] [char](20) NOT NULL,
	[TENPT] [nvarchar](50) NULL,
	[TONDAU] [int] NULL,
	[PHATSINH] [int] NULL,
	[TONCUOI] [int] NULL,
 CONSTRAINT [PK_CT_BCT] PRIMARY KEY CLUSTERED 
(
	[MACTBCT] ASC,
	[MABC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CT_PSC]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CT_PSC](
	[MACTSC] [char](25) NOT NULL,
	[MAPSC] [char](25) NOT NULL,
	[MAPT] [char](20) NULL,
	[SL] [int] NULL,
	[NOIDUNG] [nvarchar](100) NULL,
	[THANHTIEN] [money] NULL,
 CONSTRAINT [ND_PK] PRIMARY KEY CLUSTERED 
(
	[MACTSC] ASC,
	[MAPSC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HIEUXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HIEUXE](
	[HIEUXE] [varchar](20) NOT NULL,
 CONSTRAINT [LOAIXE_PK] PRIMARY KEY CLUSTERED 
(
	[HIEUXE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PHIEUSUACHUA]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PHIEUSUACHUA](
	[MAPSC] [char](25) NOT NULL,
	[BIENSO] [char](10) NULL,
	[NGAYSUACHUA] [smalldatetime] NULL,
	[TONGTIEN] [money] NULL,
 CONSTRAINT [PSC_PK] PRIMARY KEY CLUSTERED 
(
	[MAPSC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PHIEUTHUTIEN]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PHIEUTHUTIEN](
	[MAPTT] [char](20) NOT NULL,
	[BIENSO] [char](10) NULL,
	[NGAYTHU] [smalldatetime] NULL,
	[SOTIENTHU] [money] NULL,
 CONSTRAINT [PTT_PK] PRIMARY KEY CLUSTERED 
(
	[MAPTT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PHUTUNG]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PHUTUNG](
	[MAPT] [char](20) NOT NULL,
	[TENPT] [nvarchar](50) NULL,
	[SL] [int] NULL,
	[DONGIA] [money] NULL,
 CONSTRAINT [PT_PK] PRIMARY KEY CLUSTERED 
(
	[MAPT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[QUYDINH]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QUYDINH](
	[SOXESUACHUATOIDA] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TAIKHOAN]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TAIKHOAN](
	[TENDANGNHAP] [char](20) NOT NULL,
	[MATKHAU] [char](20) NOT NULL,
	[QUYEN] [char](10) NOT NULL,
	[HOTEN] [nvarchar](50) NULL,
	[SDT] [char](11) NULL,
	[DIACHI] [nvarchar](50) NULL,
	[EMAIL] [char](50) NULL,
 CONSTRAINT [PK_TAIKHOAN] PRIMARY KEY CLUSTERED 
(
	[TENDANGNHAP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TIENCONG]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TIENCONG](
	[NOIDUNG] [nvarchar](100) NOT NULL,
	[TIENCONG] [money] NULL,
 CONSTRAINT [PK_TIENCONG] PRIMARY KEY CLUSTERED 
(
	[NOIDUNG] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[XE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XE](
	[BIENSO] [char](10) NOT NULL,
	[HIEUXE] [varchar](20) NULL,
	[TENCHUXE] [nvarchar](50) NULL,
	[DIACHI] [nvarchar](100) NULL,
	[DIENTHOAI] [varchar](15) NULL,
	[EMAIL] [varchar](50) NULL,
	[NGAYTIEPNHAN] [smalldatetime] NULL,
	[TIENNO] [money] NULL,
 CONSTRAINT [XE_PK] PRIMARY KEY CLUSTERED 
(
	[BIENSO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[VW_BCDT]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_BCDT]
AS
	SELECT *
	FROM BAOCAODOANHTHU, CT_BCDT
	WHERE BAOCAODOANHTHU.MABCDT = CT_BCDT.MABC
GO
/****** Object:  View [dbo].[VW_BCVT]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[VW_BCVT]
AS
	SELECT *
	FROM CT_BCT, BAOCAOTON
	WHERE CT_BCT.MABC=BAOCAOTON.MABCT
GO
/****** Object:  View [dbo].[VW_PHIEUSUAXE]    Script Date: 7/10/2016 6:43:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_PHIEUSUAXE]
AS
SELECT        dbo.CT_PSC.MAPSC, dbo.CT_PSC.SL, dbo.CT_PSC.NOIDUNG, dbo.CT_PSC.THANHTIEN, dbo.PHIEUSUACHUA.MAPSC AS Expr1, dbo.PHIEUSUACHUA.BIENSO, dbo.PHIEUSUACHUA.TONGTIEN, 
                         dbo.PHUTUNG.TENPT, dbo.PHUTUNG.DONGIA, dbo.TIENCONG.TIENCONG
FROM            dbo.CT_PSC INNER JOIN
                         dbo.PHIEUSUACHUA ON dbo.CT_PSC.MAPSC = dbo.PHIEUSUACHUA.MAPSC AND dbo.CT_PSC.MAPSC = dbo.PHIEUSUACHUA.MAPSC INNER JOIN
                         dbo.PHUTUNG ON dbo.CT_PSC.MAPT = dbo.PHUTUNG.MAPT INNER JOIN
                         dbo.TIENCONG ON dbo.CT_PSC.NOIDUNG = dbo.TIENCONG.NOIDUNG

GO
INSERT [dbo].[HIEUXE] ([HIEUXE]) VALUES (N'AUDI')
INSERT [dbo].[HIEUXE] ([HIEUXE]) VALUES (N'BMW')
INSERT [dbo].[HIEUXE] ([HIEUXE]) VALUES (N'BOSCH')
INSERT [dbo].[HIEUXE] ([HIEUXE]) VALUES (N'FORD')
INSERT [dbo].[HIEUXE] ([HIEUXE]) VALUES (N'HONDA')
INSERT [dbo].[HIEUXE] ([HIEUXE]) VALUES (N'HYUNDAI')
INSERT [dbo].[HIEUXE] ([HIEUXE]) VALUES (N'KIA')
INSERT [dbo].[HIEUXE] ([HIEUXE]) VALUES (N'MITSUBISHI')
INSERT [dbo].[HIEUXE] ([HIEUXE]) VALUES (N'SUZUKI')
INSERT [dbo].[HIEUXE] ([HIEUXE]) VALUES (N'TAOLOA')
INSERT [dbo].[HIEUXE] ([HIEUXE]) VALUES (N'TOYOTA')
INSERT [dbo].[HIEUXE] ([HIEUXE]) VALUES (N'YAMAHA')
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_001          ', N'TEM NHAN (18 X 1000PCS)', 100, 11689242.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_002          ', N'BO GIU SACH XE', 100, 912300.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_003          ', N'NON KY THUAT VIEN', 100, 27250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_004          ', N'GIAY KY THUAT VIEN 39', 100, 348450.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_005          ', N'GIAY KY THUAT VIEN 40', 100, 348450.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_006          ', N'GIAY KY THUAT VIEN 41', 100, 348450.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_007          ', N'GIAY KY THUAT VIEN 42', 100, 348450.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_009          ', N'NUT', 100, 43750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_010          ', N'RON DAU XYLANH', 100, 1271250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_011          ', N'CAM BIEN	', 100, 696250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_012          ', N'NAP DAU XYLANH', 100, 1201250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_013          ', N'ONG HOI', 100, 93750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_014          ', N'NAP', 100, 566250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_015          ', N'BO XYLANH', 100, 42067000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_016          ', N'BAT NOI LY HOP', 100, 270000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_017          ', N'RON KIN', 100, 67500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_018          ', N'CACTE DAI CAM', 100, 153750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_019          ', N'BO RON MAY', 100, 2580000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_020          ', N'CACTE NHOT', 100, 1997500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_021          ', N'GIA DO, MAY PHAT', 100, 505000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_022          ', N'CAO SU DEM', 100, 70000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_023          ', N'CANG TANG DUA MAY PHAT', 100, 392500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_024          ', N'VONG CHINH BAC DAN CAU', 100, 227500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_025          ', N'BULONG', 100, 47500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_026          ', N'VONG CHAN', 100, 107500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_027          ', N'CAO SU CHAN MAY SAU', 100, 686250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_028          ', N'BAT CHAN', 100, 30000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_029          ', N'THANH DO DONG CO', 100, 2573750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_030          ', N'GIA TRUOT BAT DONG CO PHAI', 100, 1175000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_031          ', N'BAT, CAO SU CHAN MAY	', 100, 681250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_032          ', N'DEM THANH DONG CO	', 100, 60000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_033          ', N'VONG CHAN	', 100, 46250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_034          ', N'CAO SU CHAN MAY	', 100, 1721250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_035          ', N'MOC, DONG CO	', 100, 177500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_036          ', N'NHAN CANH BAO XANG	', 100, 41250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_037          ', N'PISTON	', 100, 783750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_038          ', N'BO PISTON	', 100, 783750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_039          ', N'PISTON STD	', 100, 783750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_040          ', N'PISTON CODE 0.50	', 100, 540000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_041          ', N'GA MOC', 100, 540000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_042          ', N'BO XECMANG STD	', 100, 410000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_043          ', N'BO XECMANG 0.50	', 100, 410000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_044          ', N'TRUC KHUYU	', 100, 15131250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_045          ', N'BAC DAN	', 100, 486250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_046          ', N'BANH DA	', 100, 2355000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_047          ', N'PULY TRUC KHUYU	', 100, 635000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_048          ', N'BO TRUC CAM	', 100, 5860000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_049          ', N'DAY DAI CAM	', 100, 1716250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_050          ', N'LO XO	', 100, 16250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_051          ', N'PHE	', 100, 60000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_052          ', N'VIT CHINH CO MO	', 100, 57500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_053          ', N'DAI OC	', 100, 30000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_054          ', N'SUPAP HUT	', 100, 196250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_055          ', N'SUPAP XA	', 100, 315000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_056          ', N'MONG SUPAP	', 100, 21250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_057          ', N'ONG GOP, HUT	', 100, 5143750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_058          ', N'BAT GIA CO	', 100, 212500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_059          ', N'BO GA	', 100, 19878750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_060          ', N'CAM BIEN GA	', 100, 3940000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_061          ', N'RON GA	', 100, 51250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_062          ', N'ONG DAN NUOC	', 100, 53750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_063          ', N'CAM BIEN NUOC	', 100, 1026250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_064          ', N'CAM BIEN	', 100, 1316250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_065          ', N'CAO SU DEM	', 100, 46250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_066          ', N'BO LOC GIO	', 100, 1251250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_067          ', N'PHE GAI	', 100, 66250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_068          ', N'BO KHUYECH DAI	', 100, 158750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_069          ', N'CAO SU DEM	', 100, 83750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_070          ', N'ONG DAN LAM LANH	', 100, 192500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_071          ', N'DEM KIN	', 100, 151250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_072          ', N'LOC GIO	', 100, 570000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_073          ', N'BAT	', 100, 48750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_074          ', N'ONG DAN LAM LANH, LOAI 2	', 100, 393750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_075          ', N'ONG DAN LAM LANH	', 100, 407500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_076          ', N'ONG VAO LOC GIO	', 100, 272500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_077          ', N'KHOP NOI	', 100, 60000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_078          ', N'THAM SAN TRUOC', 100, 310000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_079          ', N'ONG DAN LANH	', 100, 335000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_080          ', N'VONG DEM	', 100, 67500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_081          ', N'ONG GIO RA	', 100, 381250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_082          ', N'ONG GOP, XA	', 100, 1935000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_083          ', N'NAP CHE ONG GOP XA	', 100, 536250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_084          ', N'NAP CHE ONG GOP XA	', 100, 666250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_085          ', N'RON	', 100, 62500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_086          ', N'RON PO	', 100, 470000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_087          ', N'RON, NOI ONG PO	', 100, 242500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_088          ', N'ONG XA	', 100, 14286250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_089          ', N'CAO SU, ONG PO	', 100, 107500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_090          ', N'ONG PO	', 100, 5616250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_091          ', N'NAP	', 100, 452500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_092          ', N'LO XO	', 100, 113750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_093          ', N'BOM XANG	', 100, 4930000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_094          ', N'BOM XANG APV	', 100, 4930000.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_095          ', N'RON BOM XANG	', 100, 183750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_096          ', N'BAT BOM XANG	', 100, 186250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_097          ', N'BO CHINH LUU	', 100, 2348750.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_098          ', N'VONG DEM	', 100, 41250.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_099          ', N'BO PHUN XANG	', 100, 1707500.0000)
INSERT [dbo].[PHUTUNG] ([MAPT], [TENPT], [SL], [DONGIA]) VALUES (N'G20_PT_100          ', N'CAO SU DEM	', 100, 40000.0000)
INSERT [dbo].[QUYDINH] ([SOXESUACHUATOIDA]) VALUES (30)

INSERT [dbo].[TAIKHOAN] ([TENDANGNHAP], [MATKHAU], [QUYEN], [HOTEN], [SDT], [DIACHI], [EMAIL]) VALUES (N'admin', N'admin', N'GIAMDOC    ', N'Admin', null, null, null)
                       
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Công thay dầu bôi trơn động cơ', 0.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Bảo dưỡng vệ sinh kim phun, bướm ga, cổ hút.', 600000.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Bảo dưỡng phành bốn bánh cho xe 5 chỗ', 200000.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Bảo dưỡng phành bốn bánh cho xe 7 chỗ', 350000.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Đại tu hệ thống điện ( Không bao gồm tiền dây điện, rắc cắm, cầu chì ...)
', 250000.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Đại tu máy: làm hơi, xi lanh ...', 2500000.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Hạ hộp số ( sửa, thay lá côn, bàn ép, bi T ... )', 500000.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Kiểm tra toàn bộ kỹ thuật của xe, lên phương án sửa chữa                                ', 0.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Súc rửa két nước làm mát ( Bao gồm hóa chất xúc rửa và hóa chất pha chống lắng cặn )   ', 300000.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Thay căn chỉnh dây cua roa, bi tăng, bi tì ...trường hợp đã bị đứt dây cua roa.', 65443.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Thay dầu', 0.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Thay dây cam cua roa cam, bi tì, bi tang ...  ', 500000.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Thay dây cam cua roa cam, bi tì, bi tăng ...', 1000000.0000)
INSERT [dbo].[TIENCONG] ([NOIDUNG], [TIENCONG]) VALUES (N'Thay lọc xăng hoặc bơm xăng', 200000.0000)
INSERT [dbo].[XE] ([BIENSO], [HIEUXE], [TENCHUXE], [DIACHI], [DIENTHOAI], [EMAIL], [NGAYTIEPNHAN], [TIENNO]) VALUES (N'42A6244   ', N'HONDA', N'Nguyễn Trâm Anh', N'Q3, TPHCM', N'', N'', CAST(0xA62F0000 AS SmallDateTime), 0.0000)
INSERT [dbo].[XE] ([BIENSO], [HIEUXE], [TENCHUXE], [DIACHI], [DIENTHOAI], [EMAIL], [NGAYTIEPNHAN], [TIENNO]) VALUES (N'46N125    ', N'KIA', N'Nguyễn Thị B', N'Quận 9, TP HCM', N'0123456789', N'nguyenthiB@gmail.com', CAST(0xA62F0000 AS SmallDateTime), 0.0000)
INSERT [dbo].[XE] ([BIENSO], [HIEUXE], [TENCHUXE], [DIACHI], [DIENTHOAI], [EMAIL], [NGAYTIEPNHAN], [TIENNO]) VALUES (N'51B07769  ', N'BOSCH', N'Lê Minh Tâm', N'425 Thành Thái, HCMC', N'0989123123', N'tamleminh@gmail.com', CAST(0xA62F0000 AS SmallDateTime), 0.0000)
INSERT [dbo].[XE] ([BIENSO], [HIEUXE], [TENCHUXE], [DIACHI], [DIENTHOAI], [EMAIL], [NGAYTIEPNHAN], [TIENNO]) VALUES (N'53G943    ', N'SUZUKI', N'Nông Thị Lệ', N'Thủ Đức, TPHCM', N'0123123456', N'lent@gmail.com', CAST(0xA62F0000 AS SmallDateTime), 0.0000)
INSERT [dbo].[XE] ([BIENSO], [HIEUXE], [TENCHUXE], [DIACHI], [DIENTHOAI], [EMAIL], [NGAYTIEPNHAN], [TIENNO]) VALUES (N'59Z1011   ', N'SUZUKI', N'Trần Văn Thọ', N'23 Kha Vạn Cân, Thủ Đức', N'80563391', N'tho123@gmail.com', CAST(0xA62F0000 AS SmallDateTime), 0.0000)
INSERT [dbo].[XE] ([BIENSO], [HIEUXE], [TENCHUXE], [DIACHI], [DIENTHOAI], [EMAIL], [NGAYTIEPNHAN], [TIENNO]) VALUES (N'77L15404  ', N'HYUNDAI', N'Văn Hồng Hà', N'1029/11/28 Tran Hung Dao', N'01627330381    ', N'honghaa8@gmail.com                                ', CAST(0xA5F60000 AS SmallDateTime), 0.0000)
INSERT [dbo].[XE] ([BIENSO], [HIEUXE], [TENCHUXE], [DIACHI], [DIENTHOAI], [EMAIL], [NGAYTIEPNHAN], [TIENNO]) VALUES (N'93h28816  ', N'TOYOTA', N'Nguyễn Văn A', N'', N'', N'', CAST(0xA63F0000 AS SmallDateTime), 0.0000)
ALTER TABLE [dbo].[CT_BCDT]  WITH CHECK ADD  CONSTRAINT [CTDT_BCDT_FK] FOREIGN KEY([MABC])
REFERENCES [dbo].[BAOCAODOANHTHU] ([MABCDT])
GO
ALTER TABLE [dbo].[CT_BCDT] CHECK CONSTRAINT [CTDT_BCDT_FK]
GO
ALTER TABLE [dbo].[CT_BCT]  WITH CHECK ADD  CONSTRAINT [FK_CTBCT_BCT] FOREIGN KEY([MABC])
REFERENCES [dbo].[BAOCAOTON] ([MABCT])
GO
ALTER TABLE [dbo].[CT_BCT] CHECK CONSTRAINT [FK_CTBCT_BCT]
GO
ALTER TABLE [dbo].[CT_PSC]  WITH CHECK ADD  CONSTRAINT [CTPSC_PSC_FK] FOREIGN KEY([MAPSC])
REFERENCES [dbo].[PHIEUSUACHUA] ([MAPSC])
GO
ALTER TABLE [dbo].[CT_PSC] CHECK CONSTRAINT [CTPSC_PSC_FK]
GO
ALTER TABLE [dbo].[CT_PSC]  WITH CHECK ADD  CONSTRAINT [CTPSC_PT_FK] FOREIGN KEY([MAPT])
REFERENCES [dbo].[PHUTUNG] ([MAPT])
GO
ALTER TABLE [dbo].[CT_PSC] CHECK CONSTRAINT [CTPSC_PT_FK]
GO
ALTER TABLE [dbo].[PHIEUSUACHUA]  WITH CHECK ADD  CONSTRAINT [PSC_XE_FK] FOREIGN KEY([BIENSO])
REFERENCES [dbo].[XE] ([BIENSO])
GO
ALTER TABLE [dbo].[PHIEUSUACHUA] CHECK CONSTRAINT [PSC_XE_FK]
GO
ALTER TABLE [dbo].[PHIEUTHUTIEN]  WITH CHECK ADD  CONSTRAINT [PTT_XE_FK] FOREIGN KEY([BIENSO])
REFERENCES [dbo].[XE] ([BIENSO])
GO
ALTER TABLE [dbo].[PHIEUTHUTIEN] CHECK CONSTRAINT [PTT_XE_FK]
GO
ALTER TABLE [dbo].[XE]  WITH CHECK ADD  CONSTRAINT [XE_HX_FK] FOREIGN KEY([HIEUXE])
REFERENCES [dbo].[HIEUXE] ([HIEUXE])
GO
ALTER TABLE [dbo].[XE] CHECK CONSTRAINT [XE_HX_FK]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CT_PSC"
            Begin Extent = 
               Top = 5
               Left = 8
               Bottom = 135
               Right = 178
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "PHIEUSUACHUA"
            Begin Extent = 
               Top = 3
               Left = 479
               Bottom = 133
               Right = 655
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PHUTUNG"
            Begin Extent = 
               Top = 124
               Left = 727
               Bottom = 254
               Right = 897
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TIENCONG"
            Begin Extent = 
               Top = 141
               Left = 291
               Bottom = 237
               Right = 461
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 13
         Width = 284
         Width = 1500
         Width = 1500
         Width = 2235
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_PHIEUSUAXE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_PHIEUSUAXE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_PHIEUSUAXE'
GO
