/*
    Baseline table schema for AyurvedicClinicMgmt.
    Generated 2026-11-17 21:01 from . by Export-BaselineSchema.ps1.

    Run this against an EMPTY Azure SQL database, then run
    deploy/Apply-Database.ps1 against the same database to apply the
    migrations and seed the reference data.

    Tables first without foreign keys, then the foreign keys, so the order
    in which tables appear does not matter.

    RUN ONCE, against an EMPTY database. This is not re-runnable: most of this
    schema's column defaults are unnamed, SQL Server names those with a hash of
    the object id, and such a name differs between databases - so the guards
    around them look for names the target will never have. If this run fails,
    drop the database and start again rather than running it a second time.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

------------------------------------------------------------------ tables

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[access_group_access_levels]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[access_group_access_levels](
	[access_group_access_level_id] [int] IDENTITY(1,1) NOT NULL,
	[access_group_id] [int] NOT NULL,
	[access_level_id] [int] NOT NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[access_group_access_level_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
UNIQUE NONCLUSTERED 
(
	[access_group_id] ASC,
	[access_level_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[access_group_access_levels]') AND name = N'IX_access_group_access_levels_tenant')
CREATE NONCLUSTERED INDEX [IX_access_group_access_levels_tenant] ON [dbo].[access_group_access_levels]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_gr__creat__627A95E8]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_group_access_levels] ADD  DEFAULT (getutcdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_gr__updat__636EBA21]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_group_access_levels] ADD  DEFAULT (getutcdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_gr__is_ac__6462DE5A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_group_access_levels] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_gr__is_de__65570293]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_group_access_levels] ADD  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[access_groups]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[access_groups](
	[access_group_id] [int] IDENTITY(1,1) NOT NULL,
	[access_group_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[access_group_description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[access_group_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_access_groups_access_group_name] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[access_group_name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[access_groups]') AND name = N'IX_access_groups_tenant')
CREATE NONCLUSTERED INDEX [IX_access_groups_tenant] ON [dbo].[access_groups]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_gr__creat__33BFA6FF]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_groups] ADD  DEFAULT (getutcdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_gr__updat__34B3CB38]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_groups] ADD  DEFAULT (getutcdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_gr__is_ac__35A7EF71]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_groups] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_gr__is_de__369C13AA]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_groups] ADD  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[access_level_menus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[access_level_menus](
	[access_level_menu_id] [int] IDENTITY(1,1) NOT NULL,
	[access_level_id] [int] NOT NULL,
	[menu_id] [int] NOT NULL,
	[is_view] [bit] NOT NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[access_level_menu_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
UNIQUE NONCLUSTERED 
(
	[access_level_id] ASC,
	[menu_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[access_level_menus]') AND name = N'IX_access_level_menus_tenant')
CREATE NONCLUSTERED INDEX [IX_access_level_menus_tenant] ON [dbo].[access_level_menus]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_vi__6B0FDBE9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_menus] ADD  DEFAULT ((1)) FOR [is_view]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__creat__6C040022]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_menus] ADD  DEFAULT (getutcdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__updat__6CF8245B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_menus] ADD  DEFAULT (getutcdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_ac__6DEC4894]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_menus] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_de__6EE06CCD]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_menus] ADD  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[access_level_screens]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[access_level_screens](
	[access_level_screen_id] [int] IDENTITY(1,1) NOT NULL,
	[access_level_id] [int] NOT NULL,
	[screen_id] [int] NOT NULL,
	[is_view] [bit] NOT NULL,
	[is_read] [bit] NOT NULL,
	[is_write] [bit] NOT NULL,
	[is_delete] [bit] NOT NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[access_level_screen_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
UNIQUE NONCLUSTERED 
(
	[access_level_id] ASC,
	[screen_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[access_level_screens]') AND name = N'IX_access_level_screens_tenant')
CREATE NONCLUSTERED INDEX [IX_access_level_screens_tenant] ON [dbo].[access_level_screens]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_vi__74994623]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_screens] ADD  DEFAULT ((0)) FOR [is_view]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_re__758D6A5C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_screens] ADD  DEFAULT ((0)) FOR [is_read]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_wr__76818E95]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_screens] ADD  DEFAULT ((0)) FOR [is_write]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_de__7775B2CE]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_screens] ADD  DEFAULT ((0)) FOR [is_delete]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__creat__7869D707]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_screens] ADD  DEFAULT (getutcdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__updat__795DFB40]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_screens] ADD  DEFAULT (getutcdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_ac__7A521F79]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_screens] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_de__7B4643B2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_screens] ADD  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[access_level_section_fields]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[access_level_section_fields](
	[access_level_section_field_id] [int] IDENTITY(1,1) NOT NULL,
	[access_level_id] [int] NOT NULL,
	[section_field_id] [int] NOT NULL,
	[is_view] [bit] NOT NULL,
	[is_read] [bit] NOT NULL,
	[is_write] [bit] NOT NULL,
	[is_delete] [bit] NOT NULL,
	[is_required] [bit] NOT NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[access_level_section_field_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
UNIQUE NONCLUSTERED 
(
	[access_level_id] ASC,
	[section_field_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[access_level_section_fields]') AND name = N'IX_access_level_section_fields_tenant')
CREATE NONCLUSTERED INDEX [IX_access_level_section_fields_tenant] ON [dbo].[access_level_section_fields]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_vi__0D64F3ED]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_section_fields] ADD  DEFAULT ((0)) FOR [is_view]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_re__0E591826]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_section_fields] ADD  DEFAULT ((0)) FOR [is_read]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_wr__0F4D3C5F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_section_fields] ADD  DEFAULT ((0)) FOR [is_write]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_de__10416098]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_section_fields] ADD  DEFAULT ((0)) FOR [is_delete]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_re__113584D1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_section_fields] ADD  DEFAULT ((0)) FOR [is_required]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__creat__1229A90A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_section_fields] ADD  DEFAULT (getutcdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__updat__131DCD43]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_section_fields] ADD  DEFAULT (getutcdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_ac__1411F17C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_section_fields] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_de__150615B5]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_section_fields] ADD  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[access_level_sections]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[access_level_sections](
	[access_level_section_id] [int] IDENTITY(1,1) NOT NULL,
	[access_level_id] [int] NOT NULL,
	[section_id] [int] NOT NULL,
	[is_view] [bit] NOT NULL,
	[is_read] [bit] NOT NULL,
	[is_write] [bit] NOT NULL,
	[is_delete] [bit] NOT NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[access_level_section_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
UNIQUE NONCLUSTERED 
(
	[access_level_id] ASC,
	[section_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[access_level_sections]') AND name = N'IX_access_level_sections_tenant')
CREATE NONCLUSTERED INDEX [IX_access_level_sections_tenant] ON [dbo].[access_level_sections]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_vi__00FF1D08]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_sections] ADD  DEFAULT ((0)) FOR [is_view]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_re__01F34141]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_sections] ADD  DEFAULT ((0)) FOR [is_read]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_wr__02E7657A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_sections] ADD  DEFAULT ((0)) FOR [is_write]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_de__03DB89B3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_sections] ADD  DEFAULT ((0)) FOR [is_delete]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__creat__04CFADEC]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_sections] ADD  DEFAULT (getutcdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__updat__05C3D225]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_sections] ADD  DEFAULT (getutcdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_ac__06B7F65E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_sections] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_de__07AC1A97]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_level_sections] ADD  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[access_levels]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[access_levels](
	[access_level_id] [int] IDENTITY(1,1) NOT NULL,
	[access_level_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[access_level_description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[access_level_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_access_levels_access_level_name] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[access_level_name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[access_levels]') AND name = N'IX_access_levels_tenant')
CREATE NONCLUSTERED INDEX [IX_access_levels_tenant] ON [dbo].[access_levels]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__creat__3A6CA48E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_levels] ADD  DEFAULT (getutcdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__updat__3B60C8C7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_levels] ADD  DEFAULT (getutcdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_ac__3C54ED00]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_levels] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__access_le__is_de__3D491139]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[access_levels] ADD  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[addictions]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[addictions](
	[addiction_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[addiction_type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[other_addiction_type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[frequency] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[quantity_per_day] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[addiction_duration_years] [int] NULL,
	[start_age] [int] NULL,
	[notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[addiction_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[addictions]') AND name = N'IX_addictions_tenant')
CREATE NONCLUSTERED INDEX [IX_addictions_tenant] ON [dbo].[addictions]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__addiction__creat__76969D2E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[addictions] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__addiction__updat__778AC167]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[addictions] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__addiction__addic__75A278F5]') AND parent_object_id = OBJECT_ID(N'[dbo].[addictions]'))
ALTER TABLE [dbo].[addictions]  WITH CHECK ADD CHECK  (([addiction_type]=N'Other' OR [addiction_type]=N'Tobacco_in_teeth' OR [addiction_type]=N'Drugs' OR [addiction_type]=N'Alcohol' OR [addiction_type]=N'Gutkha' OR [addiction_type]=N'Pan_masala' OR [addiction_type]=N'Cigarette' OR [addiction_type]=N'Bidi' OR [addiction_type]=N'Tobacco' OR [addiction_type]=N'Pan' OR [addiction_type]=N'Supari'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[allergies]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[allergies](
	[allergy_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[allergy_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[allergy_type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[reaction] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[severity] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[onset_date] [date] NULL,
	[notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
 CONSTRAINT [PK_allergies] PRIMARY KEY CLUSTERED 
(
	[allergy_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[allergies]') AND name = N'IX_allergies_patient_id')
CREATE NONCLUSTERED INDEX [IX_allergies_patient_id] ON [dbo].[allergies]
(
	[patient_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[allergies]') AND name = N'IX_allergies_tenant')
CREATE NONCLUSTERED INDEX [IX_allergies_tenant] ON [dbo].[allergies]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_allergies_is_active]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[allergies] ADD  CONSTRAINT [DF_allergies_is_active]  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_allergies_created_at]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[allergies] ADD  CONSTRAINT [DF_allergies_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_allergies_updated_at]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[allergies] ADD  CONSTRAINT [DF_allergies_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[appointment_history]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[appointment_history](
	[history_id] [int] IDENTITY(1,1) NOT NULL,
	[appointment_id] [int] NOT NULL,
	[action_type] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[old_date] [date] NULL,
	[old_time] [time](7) NULL,
	[new_date] [date] NULL,
	[new_time] [time](7) NULL,
	[cancellation_reason] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cancelled_by] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[action_timestamp] [datetime2](7) NULL,
	[notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[history_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointment_history]') AND name = N'IX_appointment_history_branch')
CREATE NONCLUSTERED INDEX [IX_appointment_history_branch] ON [dbo].[appointment_history]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointment_history]') AND name = N'IX_appointment_history_tenant')
CREATE NONCLUSTERED INDEX [IX_appointment_history_tenant] ON [dbo].[appointment_history]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__actio__0FEC5ADD]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointment_history] ADD  DEFAULT (getdate()) FOR [action_timestamp]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_ah_cancel_reason]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_history]'))
ALTER TABLE [dbo].[appointment_history]  WITH CHECK ADD  CONSTRAINT [CHK_ah_cancel_reason] CHECK  (([action_type]<>'Cancelled' OR [cancelled_by] IS NOT NULL))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_ah_cancel_reason]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_history]'))
ALTER TABLE [dbo].[appointment_history] CHECK CONSTRAINT [CHK_ah_cancel_reason]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_ah_reschedule_dates]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_history]'))
ALTER TABLE [dbo].[appointment_history]  WITH CHECK ADD  CONSTRAINT [CHK_ah_reschedule_dates] CHECK  (([action_type]<>'Rescheduled' OR [old_date] IS NOT NULL AND [new_date] IS NOT NULL))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_ah_reschedule_dates]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_history]'))
ALTER TABLE [dbo].[appointment_history] CHECK CONSTRAINT [CHK_ah_reschedule_dates]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__appointme__actio__0E04126B]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_history]'))
ALTER TABLE [dbo].[appointment_history]  WITH CHECK ADD CHECK  (([action_type]='No_show' OR [action_type]='Completed' OR [action_type]='Rescheduled' OR [action_type]='Cancelled' OR [action_type]='Confirmed' OR [action_type]='Created'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__appointme__cance__0EF836A4]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_history]'))
ALTER TABLE [dbo].[appointment_history]  WITH CHECK ADD CHECK  (([cancelled_by]='System' OR [cancelled_by]='Admin' OR [cancelled_by]='Doctor' OR [cancelled_by]='Patient'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[appointment_reminders]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[appointment_reminders](
	[reminder_id] [int] IDENTITY(1,1) NOT NULL,
	[appointment_id] [int] NOT NULL,
	[reminder_type] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[reminder_schedule] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[scheduled_time] [datetime2](7) NOT NULL,
	[sent_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[sent_at] [datetime2](7) NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[reminder_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointment_reminders]') AND name = N'IX_appointment_reminders_branch')
CREATE NONCLUSTERED INDEX [IX_appointment_reminders_branch] ON [dbo].[appointment_reminders]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointment_reminders]') AND name = N'IX_appointment_reminders_tenant')
CREATE NONCLUSTERED INDEX [IX_appointment_reminders_tenant] ON [dbo].[appointment_reminders]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__sent___084B3915]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointment_reminders] ADD  DEFAULT ('Pending') FOR [sent_status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_sent_at]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_reminders]'))
ALTER TABLE [dbo].[appointment_reminders]  WITH CHECK ADD  CONSTRAINT [CHK_sent_at] CHECK  (([sent_at] IS NULL OR [sent_at]>=[scheduled_time]))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_sent_at]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_reminders]'))
ALTER TABLE [dbo].[appointment_reminders] CHECK CONSTRAINT [CHK_sent_at]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__appointme__remin__0662F0A3]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_reminders]'))
ALTER TABLE [dbo].[appointment_reminders]  WITH CHECK ADD CHECK  (([reminder_type]='Phone_call' OR [reminder_type]='WhatsApp' OR [reminder_type]='Email' OR [reminder_type]='SMS'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__appointme__remin__075714DC]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_reminders]'))
ALTER TABLE [dbo].[appointment_reminders]  WITH CHECK ADD CHECK  (([reminder_schedule]='Custom' OR [reminder_schedule]='1_day_before' OR [reminder_schedule]='2_hours_before' OR [reminder_schedule]='24_hours_before'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__appointme__sent___093F5D4E]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_reminders]'))
ALTER TABLE [dbo].[appointment_reminders]  WITH CHECK ADD CHECK  (([sent_status]='Cancelled' OR [sent_status]='Failed' OR [sent_status]='Sent' OR [sent_status]='Pending'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[appointment_slots]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[appointment_slots](
	[slot_id] [int] IDENTITY(1,1) NOT NULL,
	[doctor_id] [int] NOT NULL,
	[slot_date] [date] NOT NULL,
	[slot_time] [time](7) NOT NULL,
	[is_available] [bit] NOT NULL,
	[is_blocked] [bit] NOT NULL,
	[block_reason] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[slot_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_appointment_slots_doctor_id_slot_date_slot_time] UNIQUE NONCLUSTERED 
(
	[branch_id] ASC,
	[doctor_id] ASC,
	[slot_date] ASC,
	[slot_time] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointment_slots]') AND name = N'IX_appointment_slots_branch')
CREATE NONCLUSTERED INDEX [IX_appointment_slots_branch] ON [dbo].[appointment_slots]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointment_slots]') AND name = N'IX_appointment_slots_tenant')
CREATE NONCLUSTERED INDEX [IX_appointment_slots_tenant] ON [dbo].[appointment_slots]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__is_av__65F62111]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointment_slots] ADD  DEFAULT ((1)) FOR [is_available]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__is_bl__66EA454A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointment_slots] ADD  DEFAULT ((0)) FOR [is_blocked]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[appointment_therapies]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[appointment_therapies](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[appointment_id] [int] NOT NULL,
	[therapy_id] [int] NOT NULL,
	[sequence_order] [int] NOT NULL,
	[charge] [decimal](10, 2) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
 CONSTRAINT [PK_appointment_therapies] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_appointment_therapies] UNIQUE NONCLUSTERED 
(
	[appointment_id] ASC,
	[therapy_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointment_therapies]') AND name = N'IX_appointment_therapies_appointment')
CREATE NONCLUSTERED INDEX [IX_appointment_therapies_appointment] ON [dbo].[appointment_therapies]
(
	[appointment_id] ASC,
	[sequence_order] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointment_therapies]') AND name = N'IX_appointment_therapies_branch')
CREATE NONCLUSTERED INDEX [IX_appointment_therapies_branch] ON [dbo].[appointment_therapies]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointment_therapies]') AND name = N'IX_appointment_therapies_tenant')
CREATE NONCLUSTERED INDEX [IX_appointment_therapies_tenant] ON [dbo].[appointment_therapies]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_appointment_therapies_order]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointment_therapies] ADD  CONSTRAINT [DF_appointment_therapies_order]  DEFAULT ((1)) FOR [sequence_order]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_appointment_therapies_charge]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointment_therapies] ADD  CONSTRAINT [DF_appointment_therapies_charge]  DEFAULT ((0)) FOR [charge]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_appointment_therapies_created]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointment_therapies] ADD  CONSTRAINT [DF_appointment_therapies_created]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[appointment_therapists]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[appointment_therapists](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[appointment_id] [int] NOT NULL,
	[therapist_id] [int] NOT NULL,
	[is_primary] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
 CONSTRAINT [PK_appointment_therapists] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_appointment_therapists] UNIQUE NONCLUSTERED 
(
	[appointment_id] ASC,
	[therapist_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointment_therapists]') AND name = N'IX_appointment_therapists_appointment')
CREATE NONCLUSTERED INDEX [IX_appointment_therapists_appointment] ON [dbo].[appointment_therapists]
(
	[appointment_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointment_therapists]') AND name = N'IX_appointment_therapists_branch')
CREATE NONCLUSTERED INDEX [IX_appointment_therapists_branch] ON [dbo].[appointment_therapists]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointment_therapists]') AND name = N'IX_appointment_therapists_tenant')
CREATE NONCLUSTERED INDEX [IX_appointment_therapists_tenant] ON [dbo].[appointment_therapists]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_appointment_therapists_primary]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointment_therapists] ADD  CONSTRAINT [DF_appointment_therapists_primary]  DEFAULT ((0)) FOR [is_primary]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_appointment_therapists_created]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointment_therapists] ADD  CONSTRAINT [DF_appointment_therapists_created]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[appointments]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[appointments](
	[appointment_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[doctor_id] [int] NOT NULL,
	[appointment_date] [date] NOT NULL,
	[appointment_time] [time](7) NOT NULL,
	[end_time] [time](7) NULL,
	[appointment_type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[duration_minutes] [int] NULL,
	[reason_for_visit] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[chief_complaint] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[appointment_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[booking_channel] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[booking_date] [datetime2](7) NULL,
	[booked_by] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[priority] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[special_requirements] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[requires_fasting] [bit] NOT NULL,
	[requires_preparation] [bit] NOT NULL,
	[preparation_instructions] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[contact_phone] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[contact_email] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[reminder_sent] [bit] NOT NULL,
	[reminder_sent_at] [datetime2](7) NULL,
	[cancellation_reason] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cancelled_by] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cancellation_date] [datetime2](7) NULL,
	[consultation_fee] [decimal](10, 2) NULL,
	[payment_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[internal_notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[doctor_notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[updated_by] [int] NULL,
	[therapist_id] [int] NULL,
	[therapy_id] [int] NULL,
	[room_id] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[appointment_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointments]') AND name = N'IX_appointments_branch')
CREATE NONCLUSTERED INDEX [IX_appointments_branch] ON [dbo].[appointments]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointments]') AND name = N'IX_appointments_tenant')
CREATE NONCLUSTERED INDEX [IX_appointments_tenant] ON [dbo].[appointments]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointments]') AND name = N'IX_appointments_tenant_branch_appointmentdate_appointmenttime')
CREATE NONCLUSTERED INDEX [IX_appointments_tenant_branch_appointmentdate_appointmenttime] ON [dbo].[appointments]
(
	[tenant_id] ASC,
	[branch_id] ASC,
	[appointment_date] ASC,
	[appointment_time] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointments]') AND name = N'IX_appointments_tenant_branch_appointmentstatus')
CREATE NONCLUSTERED INDEX [IX_appointments_tenant_branch_appointmentstatus] ON [dbo].[appointments]
(
	[tenant_id] ASC,
	[branch_id] ASC,
	[appointment_status] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[appointments]') AND name = N'IX_appointments_tenant_patient')
CREATE NONCLUSTERED INDEX [IX_appointments_tenant_patient] ON [dbo].[appointments]
(
	[tenant_id] ASC,
	[patient_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__durat__725BF7F6]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointments] ADD  DEFAULT ((30)) FOR [duration_minutes]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__appoi__73501C2F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointments] ADD  DEFAULT ('Scheduled') FOR [appointment_status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__booki__762C88DA]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointments] ADD  DEFAULT (getdate()) FOR [booking_date]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__prior__7720AD13]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointments] ADD  DEFAULT ('Normal') FOR [priority]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__requi__7908F585]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointments] ADD  DEFAULT ((0)) FOR [requires_fasting]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__requi__79FD19BE]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointments] ADD  DEFAULT ((0)) FOR [requires_preparation]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__remin__7AF13DF7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointments] ADD  DEFAULT ((0)) FOR [reminder_sent]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__payme__7CD98669]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointments] ADD  DEFAULT ('Pending') FOR [payment_status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__creat__7EC1CEDB]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointments] ADD  DEFAULT (getdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__appointme__updat__7FB5F314]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[appointments] ADD  DEFAULT (getdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_duration]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [CHK_duration] CHECK  (([duration_minutes]>(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_duration]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [CHK_duration]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_end_time]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [CHK_end_time] CHECK  (([end_time]>[appointment_time]))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_end_time]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [CHK_end_time]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__appointme__appoi__74444068]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD CHECK  (([appointment_status]='Rescheduled' OR [appointment_status]='No_show' OR [appointment_status]='Cancelled' OR [appointment_status]='Completed' OR [appointment_status]='In_progress' OR [appointment_status]='Confirmed' OR [appointment_status]='Scheduled'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__appointme__booki__753864A1]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD CHECK  (([booking_channel]='WhatsApp' OR [booking_channel]='Referral' OR [booking_channel]='Mobile_app' OR [booking_channel]='Online' OR [booking_channel]='Walk_in' OR [booking_channel]='Phone'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__appointme__cance__7BE56230]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD CHECK  (([cancelled_by]='System' OR [cancelled_by]='Admin' OR [cancelled_by]='Doctor' OR [cancelled_by]='Patient'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__appointme__payme__7DCDAAA2]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD CHECK  (([payment_status]='Refunded' OR [payment_status]='Partially_paid' OR [payment_status]='Paid' OR [payment_status]='Pending'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__appointme__prior__7814D14C]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD CHECK  (([priority]='Emergency' OR [priority]='Urgent' OR [priority]='Normal'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_appointments_appointment_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [CK_appointments_appointment_type] CHECK  (([appointment_type]='Other' OR [appointment_type]='Panchkarma_session' OR [appointment_type]='Follow_up' OR [appointment_type]='New_consultation'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_appointments_appointment_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [CK_appointments_appointment_type]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ashtavidha_pariksha]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ashtavidha_pariksha](
	[ashta_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[nadi] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mutra] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mala] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[jihva] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[shabda] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sparsha] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[drik] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[akriti] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[recorded_at] [datetime2](0) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ashta_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ashtavidha_pariksha]') AND name = N'IX_ashtavidha_pariksha_branch')
CREATE NONCLUSTERED INDEX [IX_ashtavidha_pariksha_branch] ON [dbo].[ashtavidha_pariksha]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ashtavidha_pariksha]') AND name = N'IX_ashtavidha_pariksha_encounter')
CREATE NONCLUSTERED INDEX [IX_ashtavidha_pariksha_encounter] ON [dbo].[ashtavidha_pariksha]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ashtavidha_pariksha]') AND name = N'IX_ashtavidha_pariksha_tenant')
CREATE NONCLUSTERED INDEX [IX_ashtavidha_pariksha_tenant] ON [dbo].[ashtavidha_pariksha]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__ashtavidh__recor__14E61A24]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ashtavidha_pariksha] ADD  DEFAULT (sysutcdatetime()) FOR [recorded_at]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[audit_log]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[audit_log](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[table_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[record_id] [int] NOT NULL,
	[action_type] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[changed_by] [int] NULL,
	[changed_at] [datetime2](0) NOT NULL,
	[old_values] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[new_values] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ip_address] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[tenant_id] [int] NULL,
	[branch_id] [int] NULL,
	[user_id] [int] NULL,
	[username] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[log_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[audit_log]') AND name = N'IX_audit_log_branch')
CREATE NONCLUSTERED INDEX [IX_audit_log_branch] ON [dbo].[audit_log]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[audit_log]') AND name = N'IX_audit_log_date')
CREATE NONCLUSTERED INDEX [IX_audit_log_date] ON [dbo].[audit_log]
(
	[changed_at] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[audit_log]') AND name = N'IX_audit_log_table_record')
CREATE NONCLUSTERED INDEX [IX_audit_log_table_record] ON [dbo].[audit_log]
(
	[table_name] ASC,
	[record_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[audit_log]') AND name = N'IX_audit_log_tenant')
CREATE NONCLUSTERED INDEX [IX_audit_log_tenant] ON [dbo].[audit_log]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[audit_log]') AND name = N'IX_audit_log_tenant_table_record')
CREATE NONCLUSTERED INDEX [IX_audit_log_tenant_table_record] ON [dbo].[audit_log]
(
	[tenant_id] ASC,
	[table_name] ASC,
	[record_id] ASC,
	[changed_at] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[audit_log]') AND name = N'IX_audit_log_tenant_user_changed')
CREATE NONCLUSTERED INDEX [IX_audit_log_tenant_user_changed] ON [dbo].[audit_log]
(
	[tenant_id] ASC,
	[user_id] ASC,
	[changed_at] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__audit_log__chang__3CBF0154]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[audit_log] ADD  DEFAULT (sysutcdatetime()) FOR [changed_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_audit_json_new]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log]  WITH CHECK ADD  CONSTRAINT [CHK_audit_json_new] CHECK  (([new_values] IS NULL OR isjson([new_values])=(1)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_audit_json_new]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log] CHECK CONSTRAINT [CHK_audit_json_new]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_audit_json_old]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log]  WITH CHECK ADD  CONSTRAINT [CHK_audit_json_old] CHECK  (([old_values] IS NULL OR isjson([old_values])=(1)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_audit_json_old]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log] CHECK CONSTRAINT [CHK_audit_json_old]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__audit_log__actio__3BCADD1B]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log]  WITH CHECK ADD CHECK  (([action_type]=N'DELETE' OR [action_type]=N'UPDATE' OR [action_type]=N'INSERT'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ayurvedic_examination]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ayurvedic_examination](
	[exam_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[prakriti] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vikriti] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sara] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[samhanana] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[pramana] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[satmya] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[satva] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[aharashakti_jarana] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[aharashakti_abhyavarana] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vyayamashakti] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vaya] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[desha] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[kala] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[recorded_at] [datetime2](0) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[exam_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ayurvedic_examination]') AND name = N'IX_ayurvedic_examination_branch')
CREATE NONCLUSTERED INDEX [IX_ayurvedic_examination_branch] ON [dbo].[ayurvedic_examination]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ayurvedic_examination]') AND name = N'IX_ayurvedic_examination_encounter')
CREATE NONCLUSTERED INDEX [IX_ayurvedic_examination_encounter] ON [dbo].[ayurvedic_examination]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ayurvedic_examination]') AND name = N'IX_ayurvedic_examination_tenant')
CREATE NONCLUSTERED INDEX [IX_ayurvedic_examination_tenant] ON [dbo].[ayurvedic_examination]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__ayurvedic__recor__0A688BB1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[ayurvedic_examination] ADD  DEFAULT (sysutcdatetime()) FOR [recorded_at]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bill_items]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[bill_items](
	[item_id] [int] IDENTITY(1,1) NOT NULL,
	[bill_id] [int] NOT NULL,
	[item_type] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[item_description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[medicine_id] [int] NULL,
	[quantity] [decimal](10, 3) NOT NULL,
	[unit] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[unit_price] [decimal](10, 2) NOT NULL,
	[discount_percent] [decimal](5, 2) NOT NULL,
	[tax_percent] [decimal](5, 2) NOT NULL,
	[line_total] [decimal](10, 2) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[item_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bill_items]') AND name = N'IX_bill_items_bill')
CREATE NONCLUSTERED INDEX [IX_bill_items_bill] ON [dbo].[bill_items]
(
	[bill_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bill_items]') AND name = N'IX_bill_items_branch')
CREATE NONCLUSTERED INDEX [IX_bill_items_branch] ON [dbo].[bill_items]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bill_items]') AND name = N'IX_bill_items_tenant')
CREATE NONCLUSTERED INDEX [IX_bill_items_tenant] ON [dbo].[bill_items]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bill_item__quant__58671BC9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bill_items] ADD  DEFAULT ((1)) FOR [quantity]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bill_item__disco__595B4002]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bill_items] ADD  DEFAULT ((0)) FOR [discount_percent]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bill_item__tax_p__5A4F643B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bill_items] ADD  DEFAULT ((0)) FOR [tax_percent]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_bill_item_price]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items]  WITH CHECK ADD  CONSTRAINT [CHK_bill_item_price] CHECK  (([unit_price]>=(0) AND [line_total]>=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_bill_item_price]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items] CHECK CONSTRAINT [CHK_bill_item_price]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_bill_item_qty]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items]  WITH CHECK ADD  CONSTRAINT [CHK_bill_item_qty] CHECK  (([quantity]>(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_bill_item_qty]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items] CHECK CONSTRAINT [CHK_bill_item_qty]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bill_item__item___5772F790]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items]  WITH CHECK ADD CHECK  (([item_type]='Other' OR [item_type]='Service' OR [item_type]='Investigation' OR [item_type]='Panchkarma_procedure' OR [item_type]='Medicine' OR [item_type]='Consultation'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bills]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[bills](
	[bill_id] [int] IDENTITY(1,1) NOT NULL,
	[bill_number] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NULL,
	[appointment_id] [int] NULL,
	[bill_date] [date] NOT NULL,
	[bill_type] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[subtotal] [decimal](10, 2) NOT NULL,
	[discount_type] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[discount_value] [decimal](10, 2) NOT NULL,
	[discount_amount] [decimal](10, 2) NOT NULL,
	[tax_amount] [decimal](10, 2) NOT NULL,
	[total_amount] [decimal](10, 2) NOT NULL,
	[paid_amount] [decimal](10, 2) NOT NULL,
	[balance_due] [decimal](10, 2) NOT NULL,
	[bill_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[bill_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_bills_bill_number] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[bill_number] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bills]') AND name = N'IX_bills_branch')
CREATE NONCLUSTERED INDEX [IX_bills_branch] ON [dbo].[bills]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bills]') AND name = N'IX_bills_tenant')
CREATE NONCLUSTERED INDEX [IX_bills_tenant] ON [dbo].[bills]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bills]') AND name = N'IX_bills_tenant_branch_billdate')
CREATE NONCLUSTERED INDEX [IX_bills_tenant_branch_billdate] ON [dbo].[bills]
(
	[tenant_id] ASC,
	[branch_id] ASC,
	[bill_date] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bills__bill_date__436BFEE3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bills] ADD  DEFAULT (CONVERT([date],getdate())) FOR [bill_date]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bills__bill_type__4460231C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bills] ADD  DEFAULT ('OPD') FOR [bill_type]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bills__subtotal__46486B8E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bills] ADD  DEFAULT ((0)) FOR [subtotal]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bills__discount___4830B400]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bills] ADD  DEFAULT ((0)) FOR [discount_value]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bills__discount___4924D839]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bills] ADD  DEFAULT ((0)) FOR [discount_amount]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bills__tax_amoun__4A18FC72]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bills] ADD  DEFAULT ((0)) FOR [tax_amount]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bills__total_amo__4B0D20AB]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bills] ADD  DEFAULT ((0)) FOR [total_amount]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bills__paid_amou__4C0144E4]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bills] ADD  DEFAULT ((0)) FOR [paid_amount]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bills__balance_d__4CF5691D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bills] ADD  DEFAULT ((0)) FOR [balance_due]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bills__bill_stat__4DE98D56]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bills] ADD  DEFAULT ('Draft') FOR [bill_status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bills__created_a__4FD1D5C8]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bills] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bills__updated_a__50C5FA01]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bills] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_bill_amounts]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills]  WITH CHECK ADD  CONSTRAINT [CHK_bill_amounts] CHECK  (([subtotal]>=(0) AND [discount_amount]>=(0) AND [tax_amount]>=(0) AND [total_amount]>=(0) AND [paid_amount]>=(0) AND [balance_due]>=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_bill_amounts]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills] CHECK CONSTRAINT [CHK_bill_amounts]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bills__bill_stat__4EDDB18F]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills]  WITH CHECK ADD CHECK  (([bill_status]='Refunded' OR [bill_status]='Cancelled' OR [bill_status]='Paid' OR [bill_status]='Partially_paid' OR [bill_status]='Generated' OR [bill_status]='Draft'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bills__discount___473C8FC7]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills]  WITH CHECK ADD CHECK  (([discount_type]='None' OR [discount_type]='Percentage' OR [discount_type]='Flat'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_bills_bill_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills]  WITH CHECK ADD  CONSTRAINT [CK_bills_bill_type] CHECK  (([bill_type]='Mixed' OR [bill_type]='Consolidated' OR [bill_type]='Pharmacy' OR [bill_type]='Investigation' OR [bill_type]='Panchkarma' OR [bill_type]='IPD' OR [bill_type]='OPD'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_bills_bill_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills] CHECK CONSTRAINT [CK_bills_bill_type]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bowel_habits]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[bowel_habits](
	[bowel_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[frequency_per_day] [int] NOT NULL,
	[duration_in_minutes] [int] NULL,
	[urgency_present] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[urgency_minutes] [int] NULL,
	[sensation_present_on_time] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[after_taking_tea_or_coffee] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[color] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[consistency] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[blood_present] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mucus_present] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[undigested_food] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[floating_in_water] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[gas_issues] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[constipation] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[other_complaints] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[any_other_medicine] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[bowel_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bowel_habits]') AND name = N'IX_bowel_habits_branch')
CREATE NONCLUSTERED INDEX [IX_bowel_habits_branch] ON [dbo].[bowel_habits]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bowel_habits]') AND name = N'IX_bowel_habits_encounter')
CREATE NONCLUSTERED INDEX [IX_bowel_habits_encounter] ON [dbo].[bowel_habits]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bowel_habits]') AND name = N'IX_bowel_habits_tenant')
CREATE NONCLUSTERED INDEX [IX_bowel_habits_tenant] ON [dbo].[bowel_habits]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bowel_hab__creat__42E1EEFE]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bowel_habits] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__bowel_hab__updat__43D61337]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[bowel_habits] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bowel_hab__after__3B40CD36]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD CHECK  (([after_taking_tea_or_coffee]=N'No' OR [after_taking_tea_or_coffee]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bowel_hab__blood__3D2915A8]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD CHECK  (([blood_present]=N'No' OR [blood_present]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bowel_hab__consi__3C34F16F]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD CHECK  (([consistency]=N'Sticky' OR [consistency]=N'Watery' OR [consistency]=N'Loose' OR [consistency]=N'Normal' OR [consistency]=N'Hard'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bowel_hab__const__41EDCAC5]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD CHECK  (([constipation]=N'No' OR [constipation]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bowel_hab__float__40058253]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD CHECK  (([floating_in_water]=N'No' OR [floating_in_water]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bowel_hab__gas_i__40F9A68C]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD CHECK  (([gas_issues]=N'No' OR [gas_issues]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bowel_hab__mucus__3E1D39E1]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD CHECK  (([mucus_present]=N'No' OR [mucus_present]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bowel_hab__sensa__3A4CA8FD]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD CHECK  (([sensation_present_on_time]=N'No' OR [sensation_present_on_time]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bowel_hab__undig__3F115E1A]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD CHECK  (([undigested_food]=N'No' OR [undigested_food]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__bowel_hab__urgen__395884C4]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD CHECK  (([urgency_present]=N'No' OR [urgency_present]=N'Yes'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[branches]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[branches](
	[branch_id] [int] IDENTITY(1,1) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[branch_name] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[branch_code] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[address_line1] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[city] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[state] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[pincode] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[phone] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_primary] [bit] NOT NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NULL,
 CONSTRAINT [PK_branches] PRIMARY KEY CLUSTERED 
(
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_branches_name] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[branch_name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[branches]') AND name = N'IX_branches_tenant')
CREATE NONCLUSTERED INDEX [IX_branches_tenant] ON [dbo].[branches]
(
	[tenant_id] ASC,
	[is_active] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_branches_primary]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[branches] ADD  CONSTRAINT [DF_branches_primary]  DEFAULT ((0)) FOR [is_primary]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_branches_active]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[branches] ADD  CONSTRAINT [DF_branches_active]  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_branches_deleted]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[branches] ADD  CONSTRAINT [DF_branches_deleted]  DEFAULT ((0)) FOR [is_deleted]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_branches_created]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[branches] ADD  CONSTRAINT [DF_branches_created]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[current_medications]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[current_medications](
	[medication_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[medicine_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[medicine_type] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dosage] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[frequency] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[duration] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prescribing_doctor] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[start_date] [date] NULL,
	[end_date] [date] NULL,
	[is_active] [bit] NOT NULL,
	[notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[medication_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[current_medications]') AND name = N'IX_current_medications_tenant')
CREATE NONCLUSTERED INDEX [IX_current_medications_tenant] ON [dbo].[current_medications]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__current_m__is_ac__02084FDA]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[current_medications] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__current_m__creat__02FC7413]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[current_medications] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__current_m__updat__03F0984C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[current_medications] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__current_m__medic__01142BA1]') AND parent_object_id = OBJECT_ID(N'[dbo].[current_medications]'))
ALTER TABLE [dbo].[current_medications]  WITH CHECK ADD CHECK  (([medicine_type]=N'Other' OR [medicine_type]=N'Homeopathic' OR [medicine_type]=N'Allopathic' OR [medicine_type]=N'Ayurvedic'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[daily_routine]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[daily_routine](
	[routine_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[wake_up_time] [time](7) NULL,
	[morning_beverage] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[morning_beverage_cups] [int] NULL,
	[cup_enthusiasm] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[exercise] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[exercise_type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[exercise_duration] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bath_time] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bath_water_temp] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[head_bath_frequency] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[additional_notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[routine_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[daily_routine]') AND name = N'IX_daily_routine_branch')
CREATE NONCLUSTERED INDEX [IX_daily_routine_branch] ON [dbo].[daily_routine]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[daily_routine]') AND name = N'IX_daily_routine_encounter')
CREATE NONCLUSTERED INDEX [IX_daily_routine_encounter] ON [dbo].[daily_routine]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[daily_routine]') AND name = N'IX_daily_routine_tenant')
CREATE NONCLUSTERED INDEX [IX_daily_routine_tenant] ON [dbo].[daily_routine]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__daily_rou__creat__29221CFB]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[daily_routine] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__daily_rou__updat__2A164134]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[daily_routine] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__daily_rou__bath___282DF8C2]') AND parent_object_id = OBJECT_ID(N'[dbo].[daily_routine]'))
ALTER TABLE [dbo].[daily_routine]  WITH CHECK ADD CHECK  (([bath_water_temp]=N'Warm' OR [bath_water_temp]=N'Cold' OR [bath_water_temp]=N'Hot'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__daily_rou__cup_e__2645B050]') AND parent_object_id = OBJECT_ID(N'[dbo].[daily_routine]'))
ALTER TABLE [dbo].[daily_routine]  WITH CHECK ADD CHECK  (([cup_enthusiasm]=N'No' OR [cup_enthusiasm]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__daily_rou__exerc__2739D489]') AND parent_object_id = OBJECT_ID(N'[dbo].[daily_routine]'))
ALTER TABLE [dbo].[daily_routine]  WITH CHECK ADD CHECK  (([exercise]=N'No' OR [exercise]=N'Yes'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dietary_habits]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[dietary_habits](
	[diet_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[hunger_level] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[meals_per_day] [int] NULL,
	[water_intake_liters] [decimal](3, 1) NULL,
	[breakfast_timing] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[lunch_timing] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[supper_timing] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dinner_timing] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[meal_timing] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[meal_preference] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[hunger_feeling] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[food_intolerance] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[main_staple_food] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diet_type] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[tea_coffee_intake] [bit] NULL,
	[tea_coffee_cups_per_day] [int] NULL,
	[milk_intake] [bit] NULL,
	[late_night_eating] [bit] NULL,
	[outside_food_frequency] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[fruit_intake] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[fruit_intake_timing] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[diet_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[dietary_habits]') AND name = N'IX_dietary_habits_branch')
CREATE NONCLUSTERED INDEX [IX_dietary_habits_branch] ON [dbo].[dietary_habits]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[dietary_habits]') AND name = N'IX_dietary_habits_encounter')
CREATE NONCLUSTERED INDEX [IX_dietary_habits_encounter] ON [dbo].[dietary_habits]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[dietary_habits]') AND name = N'IX_dietary_habits_tenant')
CREATE NONCLUSTERED INDEX [IX_dietary_habits_tenant] ON [dbo].[dietary_habits]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__dietary_h__creat__339FAB6E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[dietary_habits] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__dietary_h__updat__3493CFA7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[dietary_habits] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__dietary_h__diet___31B762FC]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits]  WITH CHECK ADD CHECK  (([diet_type]=N'Eggetarian' OR [diet_type]=N'Vegan' OR [diet_type]=N'Non_vegetarian' OR [diet_type]=N'Vegetarian'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__dietary_h__fruit__32AB8735]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits]  WITH CHECK ADD CHECK  (([fruit_intake_timing]=N'Other_Time' OR [fruit_intake_timing]=N'After_Meal' OR [fruit_intake_timing]=N'During_Meal' OR [fruit_intake_timing]=N'Before_Meal'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__dietary_h__hunge__30C33EC3]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits]  WITH CHECK ADD CHECK  (([hunger_feeling]=N'Not_at_all' OR [hunger_feeling]=N'Sometimes' OR [hunger_feeling]=N'No' OR [hunger_feeling]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__dietary_h__meal___2EDAF651]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits]  WITH CHECK ADD CHECK  (([meal_timing]=N'Irregular' OR [meal_timing]=N'Regular'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__dietary_h__meal___2FCF1A8A]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits]  WITH CHECK ADD CHECK  (([meal_preference]=N'Irregular' OR [meal_preference]=N'After_hunger' OR [meal_preference]=N'During_hunger' OR [meal_preference]=N'Before_hunger'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[doctor_schedule]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[doctor_schedule](
	[schedule_id] [int] IDENTITY(1,1) NOT NULL,
	[doctor_id] [int] NOT NULL,
	[day_of_week] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[start_time] [time](7) NOT NULL,
	[end_time] [time](7) NOT NULL,
	[slot_duration_minutes] [int] NULL,
	[max_patients_per_slot] [int] NULL,
	[is_active] [bit] NOT NULL,
	[effective_from] [date] NULL,
	[effective_to] [date] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[schedule_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[doctor_schedule]') AND name = N'IX_doctor_schedule_branch')
CREATE NONCLUSTERED INDEX [IX_doctor_schedule_branch] ON [dbo].[doctor_schedule]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[doctor_schedule]') AND name = N'IX_doctor_schedule_tenant')
CREATE NONCLUSTERED INDEX [IX_doctor_schedule_tenant] ON [dbo].[doctor_schedule]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__doctor_sc__slot___5B78929E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[doctor_schedule] ADD  DEFAULT ((30)) FOR [slot_duration_minutes]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__doctor_sc__max_p__5C6CB6D7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[doctor_schedule] ADD  DEFAULT ((1)) FOR [max_patients_per_slot]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__doctor_sc__is_ac__5D60DB10]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[doctor_schedule] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_effective_dates]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule]  WITH CHECK ADD  CONSTRAINT [CHK_effective_dates] CHECK  (([effective_to] IS NULL OR [effective_to]>=[effective_from]))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_effective_dates]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule] CHECK CONSTRAINT [CHK_effective_dates]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_max_patients]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule]  WITH CHECK ADD  CONSTRAINT [CHK_max_patients] CHECK  (([max_patients_per_slot]>(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_max_patients]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule] CHECK CONSTRAINT [CHK_max_patients]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_schedule_times]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule]  WITH CHECK ADD  CONSTRAINT [CHK_schedule_times] CHECK  (([end_time]>[start_time]))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_schedule_times]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule] CHECK CONSTRAINT [CHK_schedule_times]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_slot_duration]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule]  WITH CHECK ADD  CONSTRAINT [CHK_slot_duration] CHECK  (([slot_duration_minutes]>(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_slot_duration]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule] CHECK CONSTRAINT [CHK_slot_duration]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__doctor_sc__day_o__5A846E65]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule]  WITH CHECK ADD CHECK  (([day_of_week]='Sunday' OR [day_of_week]='Saturday' OR [day_of_week]='Friday' OR [day_of_week]='Thursday' OR [day_of_week]='Wednesday' OR [day_of_week]='Tuesday' OR [day_of_week]='Monday'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[doctors]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[doctors](
	[doctor_id] [int] IDENTITY(1,1) NOT NULL,
	[doctor_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[qualification] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[specialization] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[registration_number] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[phone] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[email] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[consultation_fee] [decimal](10, 2) NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[doctor_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_doctors_registration_number] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[registration_number] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[doctors]') AND name = N'IX_doctors_name')
CREATE NONCLUSTERED INDEX [IX_doctors_name] ON [dbo].[doctors]
(
	[doctor_name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[doctors]') AND name = N'IX_doctors_tenant')
CREATE NONCLUSTERED INDEX [IX_doctors_tenant] ON [dbo].[doctors]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__doctors__is_acti__55BFB948]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[doctors] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__doctors__created__56B3DD81]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[doctors] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_doctor_fee]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctors]'))
ALTER TABLE [dbo].[doctors]  WITH CHECK ADD  CONSTRAINT [CHK_doctor_fee] CHECK  (([consultation_fee]>=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_doctor_fee]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctors]'))
ALTER TABLE [dbo].[doctors] CHECK CONSTRAINT [CHK_doctor_fee]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[encounter_diagnosis](
	[diagnosis_id] [int] IDENTITY(1,1) NOT NULL,
	[encounter_id] [int] NOT NULL,
	[patient_id] [int] NOT NULL,
	[roga_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ayurvedic_diagnosis] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[modern_diagnosis] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diagnosis_type] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dosha_involved] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dushya] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[srotas] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[avastha] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diagnosis_date] [date] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[diagnosis_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]') AND name = N'IX_encounter_diagnosis_branch')
CREATE NONCLUSTERED INDEX [IX_encounter_diagnosis_branch] ON [dbo].[encounter_diagnosis]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]') AND name = N'IX_encounter_diagnosis_encounter')
CREATE NONCLUSTERED INDEX [IX_encounter_diagnosis_encounter] ON [dbo].[encounter_diagnosis]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]') AND name = N'IX_encounter_diagnosis_tenant')
CREATE NONCLUSTERED INDEX [IX_encounter_diagnosis_tenant] ON [dbo].[encounter_diagnosis]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__encounter__diagn__2610A626]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]'))
ALTER TABLE [dbo].[encounter_diagnosis]  WITH CHECK ADD CHECK  (([diagnosis_type]=N'Final' OR [diagnosis_type]=N'Provisional' OR [diagnosis_type]=N'Differential' OR [diagnosis_type]=N'Secondary' OR [diagnosis_type]=N'Primary'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[encounter_notes]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[encounter_notes](
	[note_id] [int] IDENTITY(1,1) NOT NULL,
	[encounter_id] [int] NOT NULL,
	[patient_id] [int] NOT NULL,
	[note_type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[note_text] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](0) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[note_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[encounter_notes]') AND name = N'IX_encounter_notes_branch')
CREATE NONCLUSTERED INDEX [IX_encounter_notes_branch] ON [dbo].[encounter_notes]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[encounter_notes]') AND name = N'IX_encounter_notes_encounter')
CREATE NONCLUSTERED INDEX [IX_encounter_notes_encounter] ON [dbo].[encounter_notes]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[encounter_notes]') AND name = N'IX_encounter_notes_tenant')
CREATE NONCLUSTERED INDEX [IX_encounter_notes_tenant] ON [dbo].[encounter_notes]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__encounter__creat__2BC97F7C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[encounter_notes] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__encounter__note___2AD55B43]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_notes]'))
ALTER TABLE [dbo].[encounter_notes]  WITH CHECK ADD CHECK  (([note_type]=N'Therapist_notes' OR [note_type]=N'Dietitian_notes' OR [note_type]=N'Doctor_observations' OR [note_type]=N'Progress_notes' OR [note_type]=N'Follow_up_notes' OR [note_type]=N'Clinical_notes'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[encounter_prescriptions](
	[prescription_id] [int] IDENTITY(1,1) NOT NULL,
	[encounter_id] [int] NOT NULL,
	[patient_id] [int] NOT NULL,
	[medicine_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[medicine_type] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dosage] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[anupana] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[frequency] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[timing] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[duration] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[quantity] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[instructions] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[dispense_status] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[dispensed_at] [datetime2](7) NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[prescription_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]') AND name = N'IX_encounter_prescriptions_branch')
CREATE NONCLUSTERED INDEX [IX_encounter_prescriptions_branch] ON [dbo].[encounter_prescriptions]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]') AND name = N'IX_encounter_prescriptions_encounter')
CREATE NONCLUSTERED INDEX [IX_encounter_prescriptions_encounter] ON [dbo].[encounter_prescriptions]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]') AND name = N'IX_encounter_prescriptions_tenant')
CREATE NONCLUSTERED INDEX [IX_encounter_prescriptions_tenant] ON [dbo].[encounter_prescriptions]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__encounter__creat__1699586C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[encounter_prescriptions] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__encounter__updat__178D7CA5]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[encounter_prescriptions] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_encounter_prescriptions_dispense_status]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[encounter_prescriptions] ADD  CONSTRAINT [DF_encounter_prescriptions_dispense_status]  DEFAULT ('Pending') FOR [dispense_status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__encounter__medic__15A53433]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]'))
ALTER TABLE [dbo].[encounter_prescriptions]  WITH CHECK ADD CHECK  (([medicine_type]=N'Other' OR [medicine_type]=N'Modern' OR [medicine_type]=N'Herbal' OR [medicine_type]=N'Patent_Ayurvedic' OR [medicine_type]=N'Classical_Ayurvedic'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[encounter_treatment_plan]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[encounter_treatment_plan](
	[treatment_plan_id] [int] IDENTITY(1,1) NOT NULL,
	[encounter_id] [int] NOT NULL,
	[patient_id] [int] NOT NULL,
	[treatment_category] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[treatment_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[treatment_details] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[duration] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[frequency] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[instructions] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[treatment_plan_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[encounter_treatment_plan]') AND name = N'IX_encounter_treatment_plan_branch')
CREATE NONCLUSTERED INDEX [IX_encounter_treatment_plan_branch] ON [dbo].[encounter_treatment_plan]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[encounter_treatment_plan]') AND name = N'IX_encounter_treatment_plan_tenant')
CREATE NONCLUSTERED INDEX [IX_encounter_treatment_plan_tenant] ON [dbo].[encounter_treatment_plan]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__encounter__treat__1C5231C2]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_treatment_plan]'))
ALTER TABLE [dbo].[encounter_treatment_plan]  WITH CHECK ADD CHECK  (([treatment_category]='Yoga' OR [treatment_category]='Dietary_changes' OR [treatment_category]='Lifestyle_modification' OR [treatment_category]='Pathya' OR [treatment_category]='Panchkarma' OR [treatment_category]='Shamana' OR [treatment_category]='Shodhana'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[family_medical_history]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[family_medical_history](
	[family_history_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[disease_type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[other_disease_type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[affected_relation] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[swakul] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[pitrukul] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[matrukul] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[family_history_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[family_medical_history]') AND name = N'IX_family_medical_history_tenant')
CREATE NONCLUSTERED INDEX [IX_family_medical_history_tenant] ON [dbo].[family_medical_history]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__family_me__creat__70DDC3D8]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[family_medical_history] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__family_me__updat__71D1E811]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[family_medical_history] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[follow_up_schedule]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[follow_up_schedule](
	[followup_id] [int] IDENTITY(1,1) NOT NULL,
	[encounter_id] [int] NOT NULL,
	[patient_id] [int] NOT NULL,
	[followup_date] [date] NOT NULL,
	[followup_reason] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[reminder_sent] [bit] NOT NULL,
	[notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[followup_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[follow_up_schedule]') AND name = N'IX_follow_up_schedule_branch')
CREATE NONCLUSTERED INDEX [IX_follow_up_schedule_branch] ON [dbo].[follow_up_schedule]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[follow_up_schedule]') AND name = N'IX_follow_up_schedule_tenant')
CREATE NONCLUSTERED INDEX [IX_follow_up_schedule_tenant] ON [dbo].[follow_up_schedule]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__follow_up__statu__2B947552]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[follow_up_schedule] ADD  DEFAULT ('Scheduled') FOR [status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__follow_up__remin__2D7CBDC4]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[follow_up_schedule] ADD  DEFAULT ((0)) FOR [reminder_sent]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__follow_up__statu__2C88998B]') AND parent_object_id = OBJECT_ID(N'[dbo].[follow_up_schedule]'))
ALTER TABLE [dbo].[follow_up_schedule]  WITH CHECK ADD CHECK  (([status]='Rescheduled' OR [status]='Cancelled' OR [status]='Completed' OR [status]='Scheduled'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[habbits]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[habbits](
	[habbit_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[habbit_type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[other_habbit_type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[habbit_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[habbits]') AND name = N'IX_habbits_tenant')
CREATE NONCLUSTERED INDEX [IX_habbits_tenant] ON [dbo].[habbits]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__habbits__created__7C4F7684]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[habbits] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__habbits__updated__7D439ABD]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[habbits] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__habbits__habbit___7B5B524B]') AND parent_object_id = OBJECT_ID(N'[dbo].[habbits]'))
ALTER TABLE [dbo].[habbits]  WITH CHECK ADD CHECK  (([habbit_type]=N'Other' OR [habbit_type]=N'Rock' OR [habbit_type]=N'Soil' OR [habbit_type]=N'Nail Biting'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[inventory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[inventory](
	[inventory_id] [int] IDENTITY(1,1) NOT NULL,
	[medicine_id] [int] NOT NULL,
	[batch_number] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[manufacture_date] [date] NULL,
	[expiry_date] [date] NOT NULL,
	[quantity_received] [decimal](10, 3) NOT NULL,
	[quantity_available] [decimal](10, 3) NOT NULL,
	[quantity_unit] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[purchase_price] [decimal](10, 2) NOT NULL,
	[selling_price] [decimal](10, 2) NOT NULL,
	[mrp] [decimal](10, 2) NULL,
	[supplier_id] [int] NULL,
	[location] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[inventory_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_inventory_medicine_id_batch_number] UNIQUE NONCLUSTERED 
(
	[branch_id] ASC,
	[medicine_id] ASC,
	[batch_number] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[inventory]') AND name = N'IX_inventory_branch')
CREATE NONCLUSTERED INDEX [IX_inventory_branch] ON [dbo].[inventory]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[inventory]') AND name = N'IX_inventory_tenant')
CREATE NONCLUSTERED INDEX [IX_inventory_tenant] ON [dbo].[inventory]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[inventory]') AND name = N'IX_inventory_tenant_branch_medicine')
CREATE NONCLUSTERED INDEX [IX_inventory_tenant_branch_medicine] ON [dbo].[inventory]
(
	[tenant_id] ASC,
	[branch_id] ASC,
	[medicine_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__inventory__is_ac__76EBA2E9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[inventory] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__inventory__creat__77DFC722]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[inventory] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__inventory__updat__78D3EB5B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[inventory] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_inv_expiry]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory]  WITH CHECK ADD  CONSTRAINT [CHK_inv_expiry] CHECK  (([expiry_date]>[manufacture_date] OR [manufacture_date] IS NULL))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_inv_expiry]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory] CHECK CONSTRAINT [CHK_inv_expiry]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_inv_price]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory]  WITH CHECK ADD  CONSTRAINT [CHK_inv_price] CHECK  (([purchase_price]>=(0) AND [selling_price]>=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_inv_price]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory] CHECK CONSTRAINT [CHK_inv_price]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_inv_qty]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory]  WITH CHECK ADD  CONSTRAINT [CHK_inv_qty] CHECK  (([quantity_received]>(0) AND [quantity_available]>=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_inv_qty]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory] CHECK CONSTRAINT [CHK_inv_qty]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[investigation_report_files]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[investigation_report_files](
	[file_id] [int] IDENTITY(1,1) NOT NULL,
	[report_id] [int] NOT NULL,
	[file_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[file_original_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[file_extension] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[file_size_bytes] [bigint] NOT NULL,
	[file_mime_type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[file_data] [varbinary](max) NOT NULL,
	[file_hash] [nvarchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_storage_type] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[file_path] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_url] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cloud_container] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cloud_metadata] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[thumbnail_data] [varbinary](max) NULL,
	[thumbnail_mime_type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_primary] [bit] NOT NULL,
	[page_number] [int] NULL,
	[upload_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[virus_scan_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[virus_scan_date] [datetime2](0) NULL,
	[is_encrypted] [bit] NOT NULL,
	[encryption_key_id] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[migrated_to_cloud_at] [datetime2](0) NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[file_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[investigation_report_files]') AND name = N'IX_investigation_report_files_branch')
CREATE NONCLUSTERED INDEX [IX_investigation_report_files_branch] ON [dbo].[investigation_report_files]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[investigation_report_files]') AND name = N'IX_investigation_report_files_tenant')
CREATE NONCLUSTERED INDEX [IX_investigation_report_files_tenant] ON [dbo].[investigation_report_files]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__investiga__file___3B0BC30C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[investigation_report_files] ADD  DEFAULT (N'Database') FOR [file_storage_type]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__investiga__is_pr__3CF40B7E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[investigation_report_files] ADD  DEFAULT ((0)) FOR [is_primary]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__investiga__uploa__3DE82FB7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[investigation_report_files] ADD  DEFAULT (N'Uploaded') FOR [upload_status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__investiga__is_en__40C49C62]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[investigation_report_files] ADD  DEFAULT ((0)) FOR [is_encrypted]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__investiga__creat__41B8C09B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[investigation_report_files] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__investiga__updat__42ACE4D4]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[investigation_report_files] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__investiga__file___3BFFE745]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_report_files]'))
ALTER TABLE [dbo].[investigation_report_files]  WITH CHECK ADD CHECK  (([file_storage_type]=N'Local_FileSystem' OR [file_storage_type]=N'Google_Cloud' OR [file_storage_type]=N'AWS_S3' OR [file_storage_type]=N'Azure_Blob' OR [file_storage_type]=N'Database'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__investiga__uploa__3EDC53F0]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_report_files]'))
ALTER TABLE [dbo].[investigation_report_files]  WITH CHECK ADD CHECK  (([upload_status]=N'Migrated' OR [upload_status]=N'Deleted' OR [upload_status]=N'Failed' OR [upload_status]=N'Uploaded' OR [upload_status]=N'Uploading'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__investiga__virus__3FD07829]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_report_files]'))
ALTER TABLE [dbo].[investigation_report_files]  WITH CHECK ADD CHECK  (([virus_scan_status]=N'Skipped' OR [virus_scan_status]=N'Failed' OR [virus_scan_status]=N'Infected' OR [virus_scan_status]=N'Clean' OR [virus_scan_status]=N'Pending'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[investigation_reports]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[investigation_reports](
	[report_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NULL,
	[report_type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[other_report_type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[report_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[report_description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[test_date] [date] NULL,
	[report_date] [date] NULL,
	[facility_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[referring_doctor] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[report_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[is_critical] [bit] NOT NULL,
	[reviewed_by] [int] NULL,
	[reviewed_at] [datetime2](0) NULL,
	[review_notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[report_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[investigation_reports]') AND name = N'IX_investigation_reports_branch')
CREATE NONCLUSTERED INDEX [IX_investigation_reports_branch] ON [dbo].[investigation_reports]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[investigation_reports]') AND name = N'IX_investigation_reports_tenant')
CREATE NONCLUSTERED INDEX [IX_investigation_reports_tenant] ON [dbo].[investigation_reports]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__investiga__repor__318258D2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[investigation_reports] ADD  DEFAULT (N'Pending') FOR [report_status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__investiga__is_cr__336AA144]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[investigation_reports] ADD  DEFAULT ((0)) FOR [is_critical]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__investiga__creat__345EC57D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[investigation_reports] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__investiga__updat__3552E9B6]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[investigation_reports] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__investiga__repor__308E3499]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_reports]'))
ALTER TABLE [dbo].[investigation_reports]  WITH CHECK ADD CHECK  (([report_type]=N'Other' OR [report_type]=N'Other_Imaging' OR [report_type]=N'Other_Lab_Test' OR [report_type]=N'Radiology' OR [report_type]=N'Pathology' OR [report_type]=N'Biopsy' OR [report_type]=N'Endoscopy' OR [report_type]=N'Echo' OR [report_type]=N'ECG' OR [report_type]=N'Ultrasound' OR [report_type]=N'MRI' OR [report_type]=N'CT_Scan' OR [report_type]=N'X_Ray' OR [report_type]=N'Stool_Test' OR [report_type]=N'Urine_Test' OR [report_type]=N'Blood_Test'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__investiga__repor__32767D0B]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_reports]'))
ALTER TABLE [dbo].[investigation_reports]  WITH CHECK ADD CHECK  (([report_status]=N'Archived' OR [report_status]=N'Reviewed' OR [report_status]=N'Pending'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[investigations]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[investigations](
	[investigation_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[test_category] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[test_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[test_date] [date] NULL,
	[result] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[normal_range] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[unit] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[abnormal_flag] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[remarks] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[report_file_path] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[lab_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[recorded_at] [datetime2](7) NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[investigation_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[investigations]') AND name = N'IX_investigations_branch')
CREATE NONCLUSTERED INDEX [IX_investigations_branch] ON [dbo].[investigations]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[investigations]') AND name = N'IX_investigations_tenant')
CREATE NONCLUSTERED INDEX [IX_investigations_tenant] ON [dbo].[investigations]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__investiga__recor__26CFC035]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[investigations] ADD  DEFAULT (getdate()) FOR [recorded_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__investiga__abnor__25DB9BFC]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigations]'))
ALTER TABLE [dbo].[investigations]  WITH CHECK ADD CHECK  (([abnormal_flag]='Critical' OR [abnormal_flag]='Low' OR [abnormal_flag]='High' OR [abnormal_flag]='Normal'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[medicines_master]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[medicines_master](
	[medicine_id] [int] IDENTITY(1,1) NOT NULL,
	[medicine_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[medicine_category] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[manufacturer] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[composition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[standard_dosage] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[form] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[shelf_life_months] [int] NULL,
	[storage_conditions] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_active] [bit] NOT NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[medicine_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[medicines_master]') AND name = N'IX_medicines_master_tenant')
CREATE NONCLUSTERED INDEX [IX_medicines_master_tenant] ON [dbo].[medicines_master]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__medicines__is_ac__3335971A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[medicines_master] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_shelf_life]') AND parent_object_id = OBJECT_ID(N'[dbo].[medicines_master]'))
ALTER TABLE [dbo].[medicines_master]  WITH CHECK ADD  CONSTRAINT [CHK_shelf_life] CHECK  (([shelf_life_months]>(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_shelf_life]') AND parent_object_id = OBJECT_ID(N'[dbo].[medicines_master]'))
ALTER TABLE [dbo].[medicines_master] CHECK CONSTRAINT [CHK_shelf_life]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__medicines___form__324172E1]') AND parent_object_id = OBJECT_ID(N'[dbo].[medicines_master]'))
ALTER TABLE [dbo].[medicines_master]  WITH CHECK ADD CHECK  (([form]='Other' OR [form]='Kwatha' OR [form]='Vati' OR [form]='Churna' OR [form]='Asava_Arishta' OR [form]='Ghrita' OR [form]='Oil' OR [form]='Powder' OR [form]='Syrup' OR [form]='Capsule' OR [form]='Tablet'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mental_health]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[mental_health](
	[mental_health_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[past_trauma] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[trauma_description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[trauma_severity] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[home_office_environment] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[chronic_stress] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[stress_level] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[stress_symptoms] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[personal_trait_anger] [bit] NULL,
	[personal_trait_short_tempered] [bit] NULL,
	[personal_trait_quarrelsome] [bit] NULL,
	[personal_trait_suspicious] [bit] NULL,
	[personal_trait_greedy] [bit] NULL,
	[personal_trait_careless] [bit] NULL,
	[personal_trait_ambitious] [bit] NULL,
	[personal_trait_jealous] [bit] NULL,
	[anger_issues] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[anger_expression] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[current_situation_satisfaction] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dissatisfaction_areas] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[change_readiness] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[guilt_about_past] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[compromise_tendency] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[loneliness] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[comparison_with_others] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[feeling_responsible] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[anxiety] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[depression_symptoms] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[mental_health_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[mental_health]') AND name = N'IX_mental_health_branch')
CREATE NONCLUSTERED INDEX [IX_mental_health_branch] ON [dbo].[mental_health]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[mental_health]') AND name = N'IX_mental_health_encounter')
CREATE NONCLUSTERED INDEX [IX_mental_health_encounter] ON [dbo].[mental_health]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[mental_health]') AND name = N'IX_mental_health_tenant')
CREATE NONCLUSTERED INDEX [IX_mental_health_tenant] ON [dbo].[mental_health]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__mental_he__creat__04AFB25B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[mental_health] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__mental_he__updat__05A3D694]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[mental_health] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__anger__7B264821]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([anger_issues]=N'No' OR [anger_issues]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__anxie__02C769E9]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([anxiety]=N'No' OR [anxiety]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__chang__7D0E9093]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([change_readiness]=N'No' OR [change_readiness]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__chron__793DFFAF]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([chronic_stress]=N'No' OR [chronic_stress]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__compa__00DF2177]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([comparison_with_others]=N'No' OR [comparison_with_others]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__compr__7EF6D905]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([compromise_tendency]=N'No' OR [compromise_tendency]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__curre__7C1A6C5A]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([current_situation_satisfaction]=N'No' OR [current_situation_satisfaction]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__depre__03BB8E22]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([depression_symptoms]=N'No' OR [depression_symptoms]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__feeli__01D345B0]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([feeling_responsible]=N'No' OR [feeling_responsible]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__guilt__7E02B4CC]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([guilt_about_past]=N'No' OR [guilt_about_past]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__lonel__7FEAFD3E]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([loneliness]=N'No' OR [loneliness]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__past___7755B73D]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([past_trauma]=N'No' OR [past_trauma]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__stres__7A3223E8]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([stress_level]=N'Very_high' OR [stress_level]=N'High' OR [stress_level]=N'Moderate' OR [stress_level]=N'Low'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__mental_he__traum__7849DB76]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD CHECK  (([trauma_severity]=N'Severe' OR [trauma_severity]=N'Moderate' OR [trauma_severity]=N'Mild'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[menus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[menus](
	[menu_id] [int] IDENTITY(1,1) NOT NULL,
	[menu_name] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[menu_description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[menu_type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[module] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[parent_menu_id] [int] NULL,
	[menu_order] [int] NOT NULL,
	[menu_icon] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[menu_url] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[menu_route] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[menu_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__menus__menu_orde__40257DE4]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[menus] ADD  DEFAULT ((0)) FOR [menu_order]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__menus__created_a__4119A21D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[menus] ADD  DEFAULT (getutcdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__menus__updated_a__420DC656]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[menus] ADD  DEFAULT (getutcdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__menus__is_active__4301EA8F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[menus] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__menus__is_delete__43F60EC8]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[menus] ADD  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[nadi_pariksha]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[nadi_pariksha](
	[nadi_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[right_hand_superficial] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[right_hand_middle] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[right_hand_deep] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[left_hand_superficial] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[left_hand_middle] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[left_hand_deep] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vata_characteristics] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[pitta_characteristics] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[kapha_characteristics] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[gati] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[vega] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bala] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[nadi_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[nadi_pariksha]') AND name = N'IX_nadi_pariksha_branch')
CREATE NONCLUSTERED INDEX [IX_nadi_pariksha_branch] ON [dbo].[nadi_pariksha]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[nadi_pariksha]') AND name = N'IX_nadi_pariksha_encounter')
CREATE NONCLUSTERED INDEX [IX_nadi_pariksha_encounter] ON [dbo].[nadi_pariksha]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[nadi_pariksha]') AND name = N'IX_nadi_pariksha_tenant')
CREATE NONCLUSTERED INDEX [IX_nadi_pariksha_tenant] ON [dbo].[nadi_pariksha]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__nadi_pari__creat__0F2D40CE]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[nadi_pariksha] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__nadi_pari__updat__10216507]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[nadi_pariksha] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[number_series]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[number_series](
	[series_id] [int] IDENTITY(1,1) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[series_key] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[period_key] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[next_value] [int] NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_number_series] PRIMARY KEY CLUSTERED 
(
	[series_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_number_series] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[series_key] ASC,
	[period_key] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_number_series_next]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[number_series] ADD  CONSTRAINT [DF_number_series_next]  DEFAULT ((1)) FOR [next_value]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_number_series_updated]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[number_series] ADD  CONSTRAINT [DF_number_series_updated]  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_number_series_next]') AND parent_object_id = OBJECT_ID(N'[dbo].[number_series]'))
ALTER TABLE [dbo].[number_series]  WITH CHECK ADD  CONSTRAINT [CK_number_series_next] CHECK  (([next_value]>=(1)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_number_series_next]') AND parent_object_id = OBJECT_ID(N'[dbo].[number_series]'))
ALTER TABLE [dbo].[number_series] CHECK CONSTRAINT [CK_number_series_next]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[panchkarma_procedures](
	[procedure_id] [int] IDENTITY(1,1) NOT NULL,
	[encounter_id] [int] NOT NULL,
	[patient_id] [int] NOT NULL,
	[procedure_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[procedure_type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[procedure_date] [date] NULL,
	[duration] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[materials_used] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[observations] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[result] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[performed_by] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[therapy_id] [int] NULL,
	[instructions] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[procedure_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]') AND name = N'IX_panchkarma_procedures_branch')
CREATE NONCLUSTERED INDEX [IX_panchkarma_procedures_branch] ON [dbo].[panchkarma_procedures]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]') AND name = N'IX_panchkarma_procedures_tenant')
CREATE NONCLUSTERED INDEX [IX_panchkarma_procedures_tenant] ON [dbo].[panchkarma_procedures]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__panchkarm__proce__2116E6DF]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]'))
ALTER TABLE [dbo].[panchkarma_procedures]  WITH CHECK ADD CHECK  (([procedure_type]='Other' OR [procedure_type]='Swedana' OR [procedure_type]='Snehana' OR [procedure_type]='Raktamokshana' OR [procedure_type]='Nasya' OR [procedure_type]='Basti' OR [procedure_type]='Virechana' OR [procedure_type]='Vamana'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_rooms]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[panchkarma_rooms](
	[room_id] [int] IDENTITY(1,1) NOT NULL,
	[room_name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[room_code] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[location] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[capacity] [int] NOT NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
 CONSTRAINT [PK_panchkarma_rooms] PRIMARY KEY CLUSTERED 
(
	[room_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_panchkarma_rooms_room_name] UNIQUE NONCLUSTERED 
(
	[branch_id] ASC,
	[room_name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_rooms]') AND name = N'IX_panchkarma_rooms_active')
CREATE NONCLUSTERED INDEX [IX_panchkarma_rooms_active] ON [dbo].[panchkarma_rooms]
(
	[is_active] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_rooms]') AND name = N'IX_panchkarma_rooms_branch')
CREATE NONCLUSTERED INDEX [IX_panchkarma_rooms_branch] ON [dbo].[panchkarma_rooms]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_rooms]') AND name = N'IX_panchkarma_rooms_tenant')
CREATE NONCLUSTERED INDEX [IX_panchkarma_rooms_tenant] ON [dbo].[panchkarma_rooms]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_panchkarma_rooms_capacity]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[panchkarma_rooms] ADD  CONSTRAINT [DF_panchkarma_rooms_capacity]  DEFAULT ((1)) FOR [capacity]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_panchkarma_rooms_active]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[panchkarma_rooms] ADD  CONSTRAINT [DF_panchkarma_rooms_active]  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_panchkarma_rooms_created]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[panchkarma_rooms] ADD  CONSTRAINT [DF_panchkarma_rooms_created]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_panchkarma_rooms_updated]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[panchkarma_rooms] ADD  CONSTRAINT [DF_panchkarma_rooms_updated]  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[panchkarma_sessions](
	[session_id] [int] IDENTITY(1,1) NOT NULL,
	[appointment_id] [int] NOT NULL,
	[patient_id] [int] NOT NULL,
	[therapy_id] [int] NULL,
	[therapist_id] [int] NULL,
	[doctor_id] [int] NULL,
	[room_id] [int] NULL,
	[session_date] [date] NOT NULL,
	[started_at] [datetime2](7) NULL,
	[completed_at] [datetime2](7) NULL,
	[session_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[therapy_details] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[materials_used] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[duration_minutes] [int] NULL,
	[therapist_notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[doctor_notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[patient_response] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
 CONSTRAINT [PK_panchkarma_sessions] PRIMARY KEY CLUSTERED 
(
	[session_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_panchkarma_sessions_appointment] UNIQUE NONCLUSTERED 
(
	[appointment_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]') AND name = N'IX_panchkarma_sessions_branch')
CREATE NONCLUSTERED INDEX [IX_panchkarma_sessions_branch] ON [dbo].[panchkarma_sessions]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]') AND name = N'IX_panchkarma_sessions_patient')
CREATE NONCLUSTERED INDEX [IX_panchkarma_sessions_patient] ON [dbo].[panchkarma_sessions]
(
	[patient_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]') AND name = N'IX_panchkarma_sessions_status')
CREATE NONCLUSTERED INDEX [IX_panchkarma_sessions_status] ON [dbo].[panchkarma_sessions]
(
	[session_status] ASC,
	[session_date] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]') AND name = N'IX_panchkarma_sessions_tenant')
CREATE NONCLUSTERED INDEX [IX_panchkarma_sessions_tenant] ON [dbo].[panchkarma_sessions]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_panchkarma_sessions_status]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[panchkarma_sessions] ADD  CONSTRAINT [DF_panchkarma_sessions_status]  DEFAULT ('In_progress') FOR [session_status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_panchkarma_sessions_created]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[panchkarma_sessions] ADD  CONSTRAINT [DF_panchkarma_sessions_created]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_panchkarma_sessions_updated]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[panchkarma_sessions] ADD  CONSTRAINT [DF_panchkarma_sessions_updated]  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_panchkarma_sessions_status]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions]  WITH CHECK ADD  CONSTRAINT [CK_panchkarma_sessions_status] CHECK  (([session_status]='Cancelled' OR [session_status]='Completed' OR [session_status]='In_progress'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_panchkarma_sessions_status]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions] CHECK CONSTRAINT [CK_panchkarma_sessions_status]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_therapies]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[panchkarma_therapies](
	[therapy_id] [int] IDENTITY(1,1) NOT NULL,
	[therapy_name] [nvarchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[default_duration_minutes] [int] NOT NULL,
	[standard_charge] [decimal](10, 2) NOT NULL,
	[preparation_notes] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[tenant_id] [int] NOT NULL,
 CONSTRAINT [PK_panchkarma_therapies] PRIMARY KEY CLUSTERED 
(
	[therapy_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_panchkarma_therapies_therapy_name] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[therapy_name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_therapies]') AND name = N'IX_panchkarma_therapies_active')
CREATE NONCLUSTERED INDEX [IX_panchkarma_therapies_active] ON [dbo].[panchkarma_therapies]
(
	[is_active] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[panchkarma_therapies]') AND name = N'IX_panchkarma_therapies_tenant')
CREATE NONCLUSTERED INDEX [IX_panchkarma_therapies_tenant] ON [dbo].[panchkarma_therapies]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_panchkarma_therapies_duration]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[panchkarma_therapies] ADD  CONSTRAINT [DF_panchkarma_therapies_duration]  DEFAULT ((45)) FOR [default_duration_minutes]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_panchkarma_therapies_charge]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[panchkarma_therapies] ADD  CONSTRAINT [DF_panchkarma_therapies_charge]  DEFAULT ((0)) FOR [standard_charge]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_panchkarma_therapies_active]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[panchkarma_therapies] ADD  CONSTRAINT [DF_panchkarma_therapies_active]  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_panchkarma_therapies_created]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[panchkarma_therapies] ADD  CONSTRAINT [DF_panchkarma_therapies_created]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_panchkarma_therapies_updated]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[panchkarma_therapies] ADD  CONSTRAINT [DF_panchkarma_therapies_updated]  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[past_medical_history]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[past_medical_history](
	[history_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[disease_name] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[other_disease_name] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[diagnosis_date] [date] NULL,
	[treatment_received] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[duration] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[current_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[history_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[past_medical_history]') AND name = N'IX_past_medical_history_tenant')
CREATE NONCLUSTERED INDEX [IX_past_medical_history_tenant] ON [dbo].[past_medical_history]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__past_medi__creat__6B24EA82]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[past_medical_history] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__past_medi__updat__6C190EBB]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[past_medical_history] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__past_medi__curre__6A30C649]') AND parent_object_id = OBJECT_ID(N'[dbo].[past_medical_history]'))
ALTER TABLE [dbo].[past_medical_history]  WITH CHECK ADD CHECK  (([current_status]=N'Recurrent' OR [current_status]=N'Ongoing' OR [current_status]=N'Cured'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[patient_encounters]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[patient_encounters](
	[encounter_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_sequence] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[encounter_date] [datetime2](0) NOT NULL,
	[encounter_type] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[visit_reason] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[chief_complaint] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[encounter_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[staff_id] [int] NULL,
	[referring_doctor] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[department] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[appointment_id] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_patient_encounters_encounter_sequence] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[encounter_sequence] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[patient_encounters]') AND name = N'IX_encounters_date')
CREATE NONCLUSTERED INDEX [IX_encounters_date] ON [dbo].[patient_encounters]
(
	[encounter_date] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[patient_encounters]') AND name = N'IX_encounters_patient')
CREATE NONCLUSTERED INDEX [IX_encounters_patient] ON [dbo].[patient_encounters]
(
	[patient_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[patient_encounters]') AND name = N'IX_patient_encounters_branch')
CREATE NONCLUSTERED INDEX [IX_patient_encounters_branch] ON [dbo].[patient_encounters]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[patient_encounters]') AND name = N'IX_patient_encounters_tenant')
CREATE NONCLUSTERED INDEX [IX_patient_encounters_tenant] ON [dbo].[patient_encounters]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[patient_encounters]') AND name = N'IX_patient_encounters_tenant_patient')
CREATE NONCLUSTERED INDEX [IX_patient_encounters_tenant_patient] ON [dbo].[patient_encounters]
(
	[tenant_id] ASC,
	[patient_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__patient_e__encou__0F624AF8]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[patient_encounters] ADD  DEFAULT (N'Scheduled') FOR [encounter_status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__patient_e__creat__114A936A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[patient_encounters] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__patient_e__updat__123EB7A3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[patient_encounters] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__patient_e__encou__0E6E26BF]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_encounters]'))
ALTER TABLE [dbo].[patient_encounters]  WITH CHECK ADD CHECK  (([encounter_type]=N'Panchkarma_session' OR [encounter_type]=N'Consultation' OR [encounter_type]=N'Emergency' OR [encounter_type]=N'Follow_up' OR [encounter_type]=N'New_patient'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__patient_e__encou__10566F31]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_encounters]'))
ALTER TABLE [dbo].[patient_encounters]  WITH CHECK ADD CHECK  (([encounter_status]=N'No_show' OR [encounter_status]=N'Cancelled' OR [encounter_status]=N'Completed' OR [encounter_status]=N'In_progress' OR [encounter_status]=N'Scheduled'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[patient_occupation]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[patient_occupation](
	[occupation_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[occupation_type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[occupation_details] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[work_nature] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[work_environment] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[shift_type] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[work_hours_per_day] [decimal](4, 2) NULL,
	[vehicle_usage] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[travel_frequency] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[travel_duration_per_day] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[updated_at] [datetime2](7) NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[occupation_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
UNIQUE NONCLUSTERED 
(
	[patient_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[patient_occupation]') AND name = N'IX_patient_occupation_tenant')
CREATE NONCLUSTERED INDEX [IX_patient_occupation_tenant] ON [dbo].[patient_occupation]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__patient_o__updat__5812160E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[patient_occupation] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__patient_o__occup__534D60F1]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_occupation]'))
ALTER TABLE [dbo].[patient_occupation]  WITH CHECK ADD CHECK  (([occupation_type]=N'Other' OR [occupation_type]=N'Homemaker' OR [occupation_type]=N'Retired' OR [occupation_type]=N'Student' OR [occupation_type]=N'Business' OR [occupation_type]=N'Job' OR [occupation_type]=N'Self_employed'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__patient_o__shift__5629CD9C]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_occupation]'))
ALTER TABLE [dbo].[patient_occupation]  WITH CHECK ADD CHECK  (([shift_type]=N'Fixed' OR [shift_type]=N'Rotational' OR [shift_type]=N'Night' OR [shift_type]=N'Day'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__patient_o__vehic__571DF1D5]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_occupation]'))
ALTER TABLE [dbo].[patient_occupation]  WITH CHECK ADD CHECK  (([vehicle_usage]=N'None' OR [vehicle_usage]=N'Both' OR [vehicle_usage]=N'Four_wheeler' OR [vehicle_usage]=N'Two_wheeler'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__patient_o__work___5441852A]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_occupation]'))
ALTER TABLE [dbo].[patient_occupation]  WITH CHECK ADD CHECK  (([work_nature]=N'Other' OR [work_nature]=N'Mixed' OR [work_nature]=N'Physical_labor' OR [work_nature]=N'Mental_stress' OR [work_nature]=N'Walking' OR [work_nature]=N'Sitting'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__patient_o__work___5535A963]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_occupation]'))
ALTER TABLE [dbo].[patient_occupation]  WITH CHECK ADD CHECK  (([work_environment]=N'Other' OR [work_environment]=N'Indoor' OR [work_environment]=N'Outdoor' OR [work_environment]=N'Cold' OR [work_environment]=N'Hot' OR [work_environment]=N'Air_conditioned'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[patients]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[patients](
	[patient_id] [int] IDENTITY(1,1) NOT NULL,
	[registration_number] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[first_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[middle_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[date_of_birth] [date] NOT NULL,
	[birth_time] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[gender] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[birth_place] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[education] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[phone_country_code] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[phone] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[alternate_phone] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[whatsapp_phone] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[email] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[address_line1] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[address_line2] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[city] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[state] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[pincode] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[country] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[blood_group] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[marital_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[emergency_contact_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[emergency_contact_phone] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[emergency_contact_relation] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[registration_date] [date] NOT NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[history_completed] [bit] NOT NULL,
	[history_completed_at] [datetime2](7) NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[patient_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_patients_registration_number] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[registration_number] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[patients]') AND name = N'IX_patients_is_active')
CREATE NONCLUSTERED INDEX [IX_patients_is_active] ON [dbo].[patients]
(
	[is_active] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[patients]') AND name = N'IX_patients_phone')
CREATE NONCLUSTERED INDEX [IX_patients_phone] ON [dbo].[patients]
(
	[phone] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[patients]') AND name = N'IX_patients_reg_number')
CREATE NONCLUSTERED INDEX [IX_patients_reg_number] ON [dbo].[patients]
(
	[registration_number] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[patients]') AND name = N'IX_patients_tenant')
CREATE NONCLUSTERED INDEX [IX_patients_tenant] ON [dbo].[patients]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[patients]') AND name = N'IX_patients_tenant_phone')
CREATE NONCLUSTERED INDEX [IX_patients_tenant_phone] ON [dbo].[patients]
(
	[tenant_id] ASC,
	[phone] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__patients__countr__4BAC3F29]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[patients] ADD  DEFAULT (N'India') FOR [country]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__patients__is_act__4D94879B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[patients] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__patients__create__4E88ABD4]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[patients] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__patients__update__4F7CD00D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[patients] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_patients_history_completed]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[patients] ADD  CONSTRAINT [DF_patients_history_completed]  DEFAULT ((0)) FOR [history_completed]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__patients__gender__4AB81AF0]') AND parent_object_id = OBJECT_ID(N'[dbo].[patients]'))
ALTER TABLE [dbo].[patients]  WITH CHECK ADD CHECK  (([gender]=N'Other' OR [gender]=N'Female' OR [gender]=N'Male'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_patients_marital_status]') AND parent_object_id = OBJECT_ID(N'[dbo].[patients]'))
ALTER TABLE [dbo].[patients]  WITH CHECK ADD  CONSTRAINT [CK_patients_marital_status] CHECK  (([marital_status]=N'Widowed' OR [marital_status]=N'Divorced' OR [marital_status]=N'Single' OR [marital_status]=N'Unmarried' OR [marital_status]=N'Married'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_patients_marital_status]') AND parent_object_id = OBJECT_ID(N'[dbo].[patients]'))
ALTER TABLE [dbo].[patients] CHECK CONSTRAINT [CK_patients_marital_status]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[payments]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[payments](
	[payment_id] [int] IDENTITY(1,1) NOT NULL,
	[payment_number] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[bill_id] [int] NOT NULL,
	[patient_id] [int] NOT NULL,
	[payment_date] [datetime2](0) NOT NULL,
	[amount] [decimal](10, 2) NOT NULL,
	[payment_mode] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[transaction_ref] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[payment_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[remarks] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[created_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[payment_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_payments_payment_number] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[payment_number] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[payments]') AND name = N'IX_payments_branch')
CREATE NONCLUSTERED INDEX [IX_payments_branch] ON [dbo].[payments]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[payments]') AND name = N'IX_payments_tenant')
CREATE NONCLUSTERED INDEX [IX_payments_tenant] ON [dbo].[payments]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[payments]') AND name = N'IX_payments_tenant_branch_paymentdate')
CREATE NONCLUSTERED INDEX [IX_payments_tenant_branch_paymentdate] ON [dbo].[payments]
(
	[tenant_id] ASC,
	[branch_id] ASC,
	[payment_date] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__payments__paymen__61F08603]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[payments] ADD  DEFAULT (sysutcdatetime()) FOR [payment_date]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__payments__paymen__63D8CE75]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[payments] ADD  DEFAULT ('Completed') FOR [payment_status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__payments__create__65C116E7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[payments] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_payment_amount]') AND parent_object_id = OBJECT_ID(N'[dbo].[payments]'))
ALTER TABLE [dbo].[payments]  WITH CHECK ADD  CONSTRAINT [CHK_payment_amount] CHECK  (([amount]>(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_payment_amount]') AND parent_object_id = OBJECT_ID(N'[dbo].[payments]'))
ALTER TABLE [dbo].[payments] CHECK CONSTRAINT [CHK_payment_amount]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__payments__paymen__62E4AA3C]') AND parent_object_id = OBJECT_ID(N'[dbo].[payments]'))
ALTER TABLE [dbo].[payments]  WITH CHECK ADD CHECK  (([payment_mode]='Wallet' OR [payment_mode]='Online' OR [payment_mode]='Cheque' OR [payment_mode]='Net_banking' OR [payment_mode]='Card' OR [payment_mode]='UPI' OR [payment_mode]='Cash'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__payments__paymen__64CCF2AE]') AND parent_object_id = OBJECT_ID(N'[dbo].[payments]'))
ALTER TABLE [dbo].[payments]  WITH CHECK ADD CHECK  (([payment_status]='Refunded' OR [payment_status]='Failed' OR [payment_status]='Pending' OR [payment_status]='Completed'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[perspiration]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[perspiration](
	[sweda_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[sweat_amount] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[sweat_timing] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[summer_sweat] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sweat_odor] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[body_odor] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[night_sweats] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[stain_on_clothes] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[palm_and_feet_sweat_excessive] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ac_usage] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[sweda_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[perspiration]') AND name = N'IX_perspiration_branch')
CREATE NONCLUSTERED INDEX [IX_perspiration_branch] ON [dbo].[perspiration]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[perspiration]') AND name = N'IX_perspiration_encounter')
CREATE NONCLUSTERED INDEX [IX_perspiration_encounter] ON [dbo].[perspiration]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[perspiration]') AND name = N'IX_perspiration_tenant')
CREATE NONCLUSTERED INDEX [IX_perspiration_tenant] ON [dbo].[perspiration]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__perspirat__creat__5BAD9CC8]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[perspiration] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__perspirat__updat__5CA1C101]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[perspiration] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__perspirat__ac_us__5AB9788F]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration]  WITH CHECK ADD CHECK  (([ac_usage]=N'No' OR [ac_usage]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__perspirat__body___56E8E7AB]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration]  WITH CHECK ADD CHECK  (([body_odor]=N'No' OR [body_odor]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__perspirat__night__57DD0BE4]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration]  WITH CHECK ADD CHECK  (([night_sweats]=N'No' OR [night_sweats]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__perspirat__palm___59C55456]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration]  WITH CHECK ADD CHECK  (([palm_and_feet_sweat_excessive]=N'No' OR [palm_and_feet_sweat_excessive]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__perspirat__stain__58D1301D]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration]  WITH CHECK ADD CHECK  (([stain_on_clothes]=N'No' OR [stain_on_clothes]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__perspirat__summe__55009F39]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration]  WITH CHECK ADD CHECK  (([summer_sweat]=N'During_work' OR [summer_sweat]=N'In_sun_only' OR [summer_sweat]=N'Excessive' OR [summer_sweat]=N'Normal'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__perspirat__sweat__540C7B00]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration]  WITH CHECK ADD CHECK  (([sweat_amount]=N'Absent' OR [sweat_amount]=N'Less' OR [sweat_amount]=N'Moderate' OR [sweat_amount]=N'Excessive'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__perspirat__sweat__55F4C372]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration]  WITH CHECK ADD CHECK  (([sweat_odor]=N'None' OR [sweat_odor]=N'Mild' OR [sweat_odor]=N'Moderate' OR [sweat_odor]=N'Strong'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[physical_examination]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[physical_examination](
	[physical_exam_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[general_appearance] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[built] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[nourishment] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[pallor] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[icterus] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cyanosis] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[clubbing] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[lymphadenopathy] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[edema] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[skin_examination] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[systemic_examination] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[recorded_at] [datetime2](0) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[physical_exam_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[physical_examination]') AND name = N'IX_physical_examination_branch')
CREATE NONCLUSTERED INDEX [IX_physical_examination_branch] ON [dbo].[physical_examination]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[physical_examination]') AND name = N'IX_physical_examination_encounter')
CREATE NONCLUSTERED INDEX [IX_physical_examination_encounter] ON [dbo].[physical_examination]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[physical_examination]') AND name = N'IX_physical_examination_tenant')
CREATE NONCLUSTERED INDEX [IX_physical_examination_tenant] ON [dbo].[physical_examination]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__physical___recor__214BF109]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[physical_examination] ADD  DEFAULT (sysutcdatetime()) FOR [recorded_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__physical___built__19AACF41]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination]  WITH CHECK ADD CHECK  (([built]=N'Obese' OR [built]=N'Medium' OR [built]=N'Thin'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__physical___clubb__1E6F845E]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination]  WITH CHECK ADD CHECK  (([clubbing]=N'Absent' OR [clubbing]=N'Present'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__physical___cyano__1D7B6025]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination]  WITH CHECK ADD CHECK  (([cyanosis]=N'Absent' OR [cyanosis]=N'Present'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__physical___edema__2057CCD0]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination]  WITH CHECK ADD CHECK  (([edema]=N'Absent' OR [edema]=N'Present'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__physical___icter__1C873BEC]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination]  WITH CHECK ADD CHECK  (([icterus]=N'Absent' OR [icterus]=N'Present'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__physical___lymph__1F63A897]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination]  WITH CHECK ADD CHECK  (([lymphadenopathy]=N'Absent' OR [lymphadenopathy]=N'Present'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__physical___nouri__1A9EF37A]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination]  WITH CHECK ADD CHECK  (([nourishment]=N'Poorly_nourished' OR [nourishment]=N'Moderately_nourished' OR [nourishment]=N'Well_nourished'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__physical___pallo__1B9317B3]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination]  WITH CHECK ADD CHECK  (([pallor]=N'Absent' OR [pallor]=N'Present'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[purchase_order_items]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[purchase_order_items](
	[po_item_id] [int] IDENTITY(1,1) NOT NULL,
	[po_id] [int] NOT NULL,
	[medicine_id] [int] NOT NULL,
	[ordered_quantity] [decimal](10, 3) NOT NULL,
	[received_quantity] [decimal](10, 3) NOT NULL,
	[unit] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[unit_price] [decimal](10, 2) NOT NULL,
	[line_total] [decimal](10, 2) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[po_item_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[purchase_order_items]') AND name = N'IX_purchase_order_items_branch')
CREATE NONCLUSTERED INDEX [IX_purchase_order_items_branch] ON [dbo].[purchase_order_items]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[purchase_order_items]') AND name = N'IX_purchase_order_items_tenant')
CREATE NONCLUSTERED INDEX [IX_purchase_order_items_tenant] ON [dbo].[purchase_order_items]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__purchase___recei__0DCF0841]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[purchase_order_items] ADD  DEFAULT ((0)) FOR [received_quantity]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_poi_qty]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_order_items]'))
ALTER TABLE [dbo].[purchase_order_items]  WITH CHECK ADD  CONSTRAINT [CHK_poi_qty] CHECK  (([ordered_quantity]>(0) AND [received_quantity]>=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_poi_qty]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_order_items]'))
ALTER TABLE [dbo].[purchase_order_items] CHECK CONSTRAINT [CHK_poi_qty]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[purchase_orders]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[purchase_orders](
	[po_id] [int] IDENTITY(1,1) NOT NULL,
	[po_number] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[supplier_id] [int] NOT NULL,
	[order_date] [date] NOT NULL,
	[expected_delivery] [date] NULL,
	[po_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[total_amount] [decimal](10, 2) NOT NULL,
	[notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[po_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_purchase_orders_po_number] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[po_number] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[purchase_orders]') AND name = N'IX_purchase_orders_branch')
CREATE NONCLUSTERED INDEX [IX_purchase_orders_branch] ON [dbo].[purchase_orders]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[purchase_orders]') AND name = N'IX_purchase_orders_tenant')
CREATE NONCLUSTERED INDEX [IX_purchase_orders_tenant] ON [dbo].[purchase_orders]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__purchase___order__0539C240]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[purchase_orders] ADD  DEFAULT (CONVERT([date],getdate())) FOR [order_date]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__purchase___po_st__062DE679]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[purchase_orders] ADD  DEFAULT ('Draft') FOR [po_status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__purchase___total__08162EEB]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[purchase_orders] ADD  DEFAULT ((0)) FOR [total_amount]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__purchase___creat__090A5324]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[purchase_orders] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__purchase___updat__09FE775D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[purchase_orders] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__purchase___po_st__07220AB2]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_orders]'))
ALTER TABLE [dbo].[purchase_orders]  WITH CHECK ADD CHECK  (([po_status]='Cancelled' OR [po_status]='Received' OR [po_status]='Partially_received' OR [po_status]='Sent' OR [po_status]='Draft'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[refresh_tokens]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[refresh_tokens](
	[token_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[token] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[expires_at] [datetime2](7) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[is_revoked] [bit] NOT NULL,
	[tenant_id] [int] NOT NULL,
 CONSTRAINT [PK_refresh_tokens] PRIMARY KEY CLUSTERED 
(
	[token_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[refresh_tokens]') AND name = N'IX_refresh_tokens_tenant')
CREATE NONCLUSTERED INDEX [IX_refresh_tokens_tenant] ON [dbo].[refresh_tokens]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[refresh_tokens]') AND name = N'IX_refresh_tokens_token')
CREATE NONCLUSTERED INDEX [IX_refresh_tokens_token] ON [dbo].[refresh_tokens]
(
	[token] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_refresh_tokens_created]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[refresh_tokens] ADD  CONSTRAINT [DF_refresh_tokens_created]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_refresh_tokens_revoked]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[refresh_tokens] ADD  CONSTRAINT [DF_refresh_tokens_revoked]  DEFAULT ((0)) FOR [is_revoked]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[refunds]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[refunds](
	[refund_id] [int] IDENTITY(1,1) NOT NULL,
	[payment_id] [int] NOT NULL,
	[bill_id] [int] NOT NULL,
	[patient_id] [int] NOT NULL,
	[refund_date] [datetime2](0) NOT NULL,
	[refund_amount] [decimal](10, 2) NOT NULL,
	[refund_mode] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[refund_reason] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[refund_status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
	[created_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[refund_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[refunds]') AND name = N'IX_refunds_branch')
CREATE NONCLUSTERED INDEX [IX_refunds_branch] ON [dbo].[refunds]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[refunds]') AND name = N'IX_refunds_tenant')
CREATE NONCLUSTERED INDEX [IX_refunds_tenant] ON [dbo].[refunds]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__refunds__refund___6B79F03D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[refunds] ADD  DEFAULT (sysutcdatetime()) FOR [refund_date]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__refunds__refund___6D6238AF]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[refunds] ADD  DEFAULT ('Processed') FOR [refund_status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__refunds__created__6F4A8121]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[refunds] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_refund_amount]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds]  WITH CHECK ADD  CONSTRAINT [CHK_refund_amount] CHECK  (([refund_amount]>(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CHK_refund_amount]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds] CHECK CONSTRAINT [CHK_refund_amount]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__refunds__refund___6C6E1476]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds]  WITH CHECK ADD CHECK  (([refund_mode]='Wallet' OR [refund_mode]='Cheque' OR [refund_mode]='Net_banking' OR [refund_mode]='Card' OR [refund_mode]='UPI' OR [refund_mode]='Cash'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__refunds__refund___6E565CE8]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds]  WITH CHECK ADD CHECK  (([refund_status]='Failed' OR [refund_status]='Pending' OR [refund_status]='Processed'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[reproductive_history]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[reproductive_history](
	[reproductive_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[sexually_satisfied] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[intercourse_frequency] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sexual_complaints] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[masturbation_habit] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[family_planning] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[contraceptive_method] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[number_of_sons] [int] NOT NULL,
	[number_of_daughters] [int] NOT NULL,
	[total_pregnancies] [int] NOT NULL,
	[miscarriage_count] [int] NOT NULL,
	[abortion_count] [int] NOT NULL,
	[gynecological_issues] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[menstrual_history] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_period_date] [datetime2](0) NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[reproductive_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
UNIQUE NONCLUSTERED 
(
	[patient_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[reproductive_history]') AND name = N'IX_reproductive_history_tenant')
CREATE NONCLUSTERED INDEX [IX_reproductive_history_tenant] ON [dbo].[reproductive_history]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__reproduct__numbe__5FB337D6]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[reproductive_history] ADD  DEFAULT ((0)) FOR [number_of_sons]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__reproduct__numbe__60A75C0F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[reproductive_history] ADD  DEFAULT ((0)) FOR [number_of_daughters]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__reproduct__total__619B8048]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[reproductive_history] ADD  DEFAULT ((0)) FOR [total_pregnancies]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__reproduct__misca__628FA481]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[reproductive_history] ADD  DEFAULT ((0)) FOR [miscarriage_count]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__reproduct__abort__6383C8BA]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[reproductive_history] ADD  DEFAULT ((0)) FOR [abortion_count]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__reproduct__creat__6477ECF3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[reproductive_history] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__reproduct__updat__656C112C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[reproductive_history] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__reproduct__famil__5EBF139D]') AND parent_object_id = OBJECT_ID(N'[dbo].[reproductive_history]'))
ALTER TABLE [dbo].[reproductive_history]  WITH CHECK ADD CHECK  (([family_planning]=N'No' OR [family_planning]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__reproduct__mastu__5DCAEF64]') AND parent_object_id = OBJECT_ID(N'[dbo].[reproductive_history]'))
ALTER TABLE [dbo].[reproductive_history]  WITH CHECK ADD CHECK  (([masturbation_habit]=N'No' OR [masturbation_habit]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__reproduct__sexua__5CD6CB2B]') AND parent_object_id = OBJECT_ID(N'[dbo].[reproductive_history]'))
ALTER TABLE [dbo].[reproductive_history]  WITH CHECK ADD CHECK  (([sexually_satisfied]=N'No' OR [sexually_satisfied]=N'Yes'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[role_access_groups]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[role_access_groups](
	[role_access_group_id] [int] IDENTITY(1,1) NOT NULL,
	[role_id] [int] NOT NULL,
	[access_group_id] [int] NOT NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[role_access_group_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
UNIQUE NONCLUSTERED 
(
	[role_id] ASC,
	[access_group_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[role_access_groups]') AND name = N'IX_role_access_groups_tenant')
CREATE NONCLUSTERED INDEX [IX_role_access_groups_tenant] ON [dbo].[role_access_groups]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__role_acce__creat__1ABEEF0B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[role_access_groups] ADD  DEFAULT (getutcdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__role_acce__updat__1BB31344]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[role_access_groups] ADD  DEFAULT (getutcdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__role_acce__is_ac__1CA7377D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[role_access_groups] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__role_acce__is_de__1D9B5BB6]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[role_access_groups] ADD  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[roles]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[roles](
	[role_id] [int] IDENTITY(1,1) NOT NULL,
	[role_name] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[tenant_id] [int] NOT NULL,
 CONSTRAINT [PK_roles] PRIMARY KEY CLUSTERED 
(
	[role_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_roles_role_name] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[role_name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[roles]') AND name = N'IX_roles_tenant')
CREATE NONCLUSTERED INDEX [IX_roles_tenant] ON [dbo].[roles]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_roles_created]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[roles] ADD  CONSTRAINT [DF_roles_created]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_roles_active]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[roles] ADD  CONSTRAINT [DF_roles_active]  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_roles_deleted]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[roles] ADD  CONSTRAINT [DF_roles_deleted]  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[screens]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[screens](
	[screen_id] [int] IDENTITY(1,1) NOT NULL,
	[screen_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[screen_description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[menu_id] [int] NULL,
	[screen_url] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[screen_route] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[screen_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
UNIQUE NONCLUSTERED 
(
	[screen_name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__screens__created__48BAC3E5]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[screens] ADD  DEFAULT (getutcdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__screens__updated__49AEE81E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[screens] ADD  DEFAULT (getutcdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__screens__is_acti__4AA30C57]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[screens] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__screens__is_dele__4B973090]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[screens] ADD  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[section_fields]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[section_fields](
	[section_field_id] [int] IDENTITY(1,1) NOT NULL,
	[screen_id] [int] NOT NULL,
	[section_id] [int] NOT NULL,
	[field_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[field_label] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[control_type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[default_value] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[placeholder_text] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[help_text] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_system_required] [bit] NOT NULL,
	[field_order] [int] NOT NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[section_field_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
UNIQUE NONCLUSTERED 
(
	[screen_id] ASC,
	[section_id] ASC,
	[field_name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__section_f__is_sy__57FD0775]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[section_fields] ADD  DEFAULT ((0)) FOR [is_system_required]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__section_f__field__58F12BAE]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[section_fields] ADD  DEFAULT ((0)) FOR [field_order]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__section_f__creat__59E54FE7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[section_fields] ADD  DEFAULT (getutcdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__section_f__updat__5AD97420]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[section_fields] ADD  DEFAULT (getutcdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__section_f__is_ac__5BCD9859]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[section_fields] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__section_f__is_de__5CC1BC92]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[section_fields] ADD  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sections]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[sections](
	[section_id] [int] IDENTITY(1,1) NOT NULL,
	[section_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[section_description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[screen_id] [int] NOT NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[section_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
UNIQUE NONCLUSTERED 
(
	[section_name] ASC,
	[screen_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__sections__create__505BE5AD]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[sections] ADD  DEFAULT (getutcdate()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__sections__update__515009E6]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[sections] ADD  DEFAULT (getutcdate()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__sections__is_act__52442E1F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[sections] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__sections__is_del__53385258]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[sections] ADD  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sensory_details]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[sensory_details](
	[sensory_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[tv_watching_hours] [decimal](4, 2) NULL,
	[computer_work_hours] [decimal](4, 2) NULL,
	[mobile_usage_hours] [decimal](4, 2) NULL,
	[reading_hours] [decimal](4, 2) NULL,
	[eye_strain] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[headache_frequency] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[sensory_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[sensory_details]') AND name = N'IX_sensory_details_branch')
CREATE NONCLUSTERED INDEX [IX_sensory_details_branch] ON [dbo].[sensory_details]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[sensory_details]') AND name = N'IX_sensory_details_encounter')
CREATE NONCLUSTERED INDEX [IX_sensory_details_encounter] ON [dbo].[sensory_details]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[sensory_details]') AND name = N'IX_sensory_details_tenant')
CREATE NONCLUSTERED INDEX [IX_sensory_details_tenant] ON [dbo].[sensory_details]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__sensory_d__creat__719CDDE7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[sensory_details] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__sensory_d__updat__72910220]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[sensory_details] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__sensory_d__eye_s__70A8B9AE]') AND parent_object_id = OBJECT_ID(N'[dbo].[sensory_details]'))
ALTER TABLE [dbo].[sensory_details]  WITH CHECK ADD CHECK  (([eye_strain]=N'No' OR [eye_strain]=N'Yes'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sleep_patterns]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[sleep_patterns](
	[sleep_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[sleep_time] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[sleep_difficulty] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[wake_up_time] [time](7) NULL,
	[total_sleep_hours] [decimal](3, 1) NULL,
	[sleep_again_after_wake] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[daytime_sleep] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[daytime_sleep_duration] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[post_meal_drowsiness] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sleep_quality] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dreams] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[snoring] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sleep_disturbances] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sleep_talking] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sleep_walking] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sleep_urinating] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[sleep_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[sleep_patterns]') AND name = N'IX_sleep_patterns_branch')
CREATE NONCLUSTERED INDEX [IX_sleep_patterns_branch] ON [dbo].[sleep_patterns]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[sleep_patterns]') AND name = N'IX_sleep_patterns_encounter')
CREATE NONCLUSTERED INDEX [IX_sleep_patterns_encounter] ON [dbo].[sleep_patterns]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[sleep_patterns]') AND name = N'IX_sleep_patterns_tenant')
CREATE NONCLUSTERED INDEX [IX_sleep_patterns_tenant] ON [dbo].[sleep_patterns]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__sleep_pat__creat__6AEFE058]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[sleep_patterns] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__sleep_pat__updat__6BE40491]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[sleep_patterns] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__sleep_pat__dayti__634EBE90]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD CHECK  (([daytime_sleep]=N'No' OR [daytime_sleep]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__sleep_pat__dream__662B2B3B]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD CHECK  (([dreams]=N'None' OR [dreams]=N'Rare' OR [dreams]=N'Occasional' OR [dreams]=N'Frequent'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__sleep_pat__post___6442E2C9]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD CHECK  (([post_meal_drowsiness]=N'No' OR [post_meal_drowsiness]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__sleep_pat__sleep__6166761E]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD CHECK  (([sleep_difficulty]=N'Occasionally' OR [sleep_difficulty]=N'Sometimes' OR [sleep_difficulty]=N'Never' OR [sleep_difficulty]=N'Always'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__sleep_pat__sleep__625A9A57]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD CHECK  (([sleep_again_after_wake]=N'No' OR [sleep_again_after_wake]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__sleep_pat__sleep__65370702]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD CHECK  (([sleep_quality]=N'Poor' OR [sleep_quality]=N'Moderate' OR [sleep_quality]=N'Good'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__sleep_pat__sleep__681373AD]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD CHECK  (([sleep_talking]=N'No' OR [sleep_talking]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__sleep_pat__sleep__690797E6]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD CHECK  (([sleep_walking]=N'No' OR [sleep_walking]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__sleep_pat__sleep__69FBBC1F]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD CHECK  (([sleep_urinating]=N'No' OR [sleep_urinating]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__sleep_pat__snori__671F4F74]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD CHECK  (([snoring]=N'No' OR [snoring]=N'Yes'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[staff]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[staff](
	[staff_id] [int] IDENTITY(1,1) NOT NULL,
	[staff_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[staff_type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[qualification] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[specialization] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[registration_number] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[phone] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[mobile] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[email] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
	[gender] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[staff_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[staff]') AND name = N'IX_staff_tenant')
CREATE NONCLUSTERED INDEX [IX_staff_tenant] ON [dbo].[staff]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[staff]') AND name = N'UX_staff_registration_number')
CREATE UNIQUE NONCLUSTERED INDEX [UX_staff_registration_number] ON [dbo].[staff]
(
	[tenant_id] ASC,
	[registration_number] ASC
)
WHERE ([registration_number] IS NOT NULL)
WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__staff__is_active__09A971A2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[staff] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__staff__created_a__0A9D95DB]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[staff] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_staff_gender]') AND parent_object_id = OBJECT_ID(N'[dbo].[staff]'))
ALTER TABLE [dbo].[staff]  WITH CHECK ADD  CONSTRAINT [CK_staff_gender] CHECK  (([gender] IS NULL OR ([gender]='Other' OR [gender]='Female' OR [gender]='Male')))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_staff_gender]') AND parent_object_id = OBJECT_ID(N'[dbo].[staff]'))
ALTER TABLE [dbo].[staff] CHECK CONSTRAINT [CK_staff_gender]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_staff_staff_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[staff]'))
ALTER TABLE [dbo].[staff]  WITH CHECK ADD  CONSTRAINT [CK_staff_staff_type] CHECK  (([staff_type]='Admin' OR [staff_type]='Receptionist' OR [staff_type]='Therapist' OR [staff_type]='Nurse' OR [staff_type]='Assistant Doctor' OR [staff_type]='Doctor'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_staff_staff_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[staff]'))
ALTER TABLE [dbo].[staff] CHECK CONSTRAINT [CK_staff_staff_type]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stock_alerts]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[stock_alerts](
	[alert_id] [int] IDENTITY(1,1) NOT NULL,
	[medicine_id] [int] NOT NULL,
	[inventory_id] [int] NULL,
	[alert_type] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[alert_message] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_resolved] [bit] NOT NULL,
	[resolved_at] [datetime2](0) NULL,
	[created_at] [datetime2](0) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[alert_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[stock_alerts]') AND name = N'IX_stock_alerts_branch')
CREATE NONCLUSTERED INDEX [IX_stock_alerts_branch] ON [dbo].[stock_alerts]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[stock_alerts]') AND name = N'IX_stock_alerts_tenant')
CREATE NONCLUSTERED INDEX [IX_stock_alerts_tenant] ON [dbo].[stock_alerts]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__stock_ale__is_re__1B29035F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[stock_alerts] ADD  DEFAULT ((0)) FOR [is_resolved]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__stock_ale__creat__1C1D2798]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[stock_alerts] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__stock_ale__alert__1A34DF26]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_alerts]'))
ALTER TABLE [dbo].[stock_alerts]  WITH CHECK ADD CHECK  (([alert_type]='Expired' OR [alert_type]='Near_expiry' OR [alert_type]='Out_of_stock' OR [alert_type]='Low_stock'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stock_transactions]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[stock_transactions](
	[txn_id] [int] IDENTITY(1,1) NOT NULL,
	[inventory_id] [int] NOT NULL,
	[medicine_id] [int] NOT NULL,
	[txn_type] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[quantity_change] [decimal](10, 3) NOT NULL,
	[quantity_before] [decimal](10, 3) NOT NULL,
	[quantity_after] [decimal](10, 3) NOT NULL,
	[reference_type] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[reference_id] [int] NULL,
	[remarks] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[txn_date] [datetime2](0) NOT NULL,
	[created_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[txn_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[stock_transactions]') AND name = N'IX_stock_transactions_branch')
CREATE NONCLUSTERED INDEX [IX_stock_transactions_branch] ON [dbo].[stock_transactions]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[stock_transactions]') AND name = N'IX_stock_transactions_tenant')
CREATE NONCLUSTERED INDEX [IX_stock_transactions_tenant] ON [dbo].[stock_transactions]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__stock_tra__txn_d__15702A09]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[stock_transactions] ADD  DEFAULT (sysutcdatetime()) FOR [txn_date]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_stock_transactions_reference_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_transactions]'))
ALTER TABLE [dbo].[stock_transactions]  WITH CHECK ADD  CONSTRAINT [CK_stock_transactions_reference_type] CHECK  (([reference_type] IS NULL OR ([reference_type]=N'Branch_transfer' OR [reference_type]=N'Expiry_removal' OR [reference_type]=N'Manual' OR [reference_type]=N'Bill' OR [reference_type]=N'Purchase_order')))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_stock_transactions_reference_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_transactions]'))
ALTER TABLE [dbo].[stock_transactions] CHECK CONSTRAINT [CK_stock_transactions_reference_type]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_stock_transactions_txn_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_transactions]'))
ALTER TABLE [dbo].[stock_transactions]  WITH CHECK ADD  CONSTRAINT [CK_stock_transactions_txn_type] CHECK  (([txn_type]=N'Transfer_in' OR [txn_type]=N'Transfer_out' OR [txn_type]=N'Return_from_patient' OR [txn_type]=N'Return_to_supplier' OR [txn_type]=N'Expired' OR [txn_type]=N'Adjustment' OR [txn_type]=N'Dispensed' OR [txn_type]=N'Purchase' OR [txn_type]=N'Opening_stock'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_stock_transactions_txn_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_transactions]'))
ALTER TABLE [dbo].[stock_transactions] CHECK CONSTRAINT [CK_stock_transactions_txn_type]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[subscription_plans]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[subscription_plans](
	[plan_id] [int] IDENTITY(1,1) NOT NULL,
	[plan_code] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[plan_name] [nvarchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[monthly_price] [decimal](18, 2) NULL,
	[currency] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[max_branches] [int] NULL,
	[max_users] [int] NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NULL,
 CONSTRAINT [PK_subscription_plans] PRIMARY KEY CLUSTERED 
(
	[plan_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_subscription_plans_code] UNIQUE NONCLUSTERED 
(
	[plan_code] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_subscription_plans_active]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[subscription_plans] ADD  CONSTRAINT [DF_subscription_plans_active]  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_subscription_plans_deleted]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[subscription_plans] ADD  CONSTRAINT [DF_subscription_plans_deleted]  DEFAULT ((0)) FOR [is_deleted]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_subscription_plans_created]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[subscription_plans] ADD  CONSTRAINT [DF_subscription_plans_created]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_subscription_plans_limits]') AND parent_object_id = OBJECT_ID(N'[dbo].[subscription_plans]'))
ALTER TABLE [dbo].[subscription_plans]  WITH CHECK ADD  CONSTRAINT [CK_subscription_plans_limits] CHECK  ((([max_branches] IS NULL OR [max_branches]>(0)) AND ([max_users] IS NULL OR [max_users]>(0))))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_subscription_plans_limits]') AND parent_object_id = OBJECT_ID(N'[dbo].[subscription_plans]'))
ALTER TABLE [dbo].[subscription_plans] CHECK CONSTRAINT [CK_subscription_plans_limits]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_subscription_plans_price]') AND parent_object_id = OBJECT_ID(N'[dbo].[subscription_plans]'))
ALTER TABLE [dbo].[subscription_plans]  WITH CHECK ADD  CONSTRAINT [CK_subscription_plans_price] CHECK  (([monthly_price] IS NULL OR [monthly_price]>=(0)))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_subscription_plans_price]') AND parent_object_id = OBJECT_ID(N'[dbo].[subscription_plans]'))
ALTER TABLE [dbo].[subscription_plans] CHECK CONSTRAINT [CK_subscription_plans_price]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[suppliers]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[suppliers](
	[supplier_id] [int] IDENTITY(1,1) NOT NULL,
	[supplier_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[contact_person] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[phone] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[email] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[address] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[gst_number] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[drug_license_number] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
	[tenant_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[supplier_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[suppliers]') AND name = N'IX_suppliers_tenant')
CREATE NONCLUSTERED INDEX [IX_suppliers_tenant] ON [dbo].[suppliers]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__suppliers__is_ac__7F80E8EA]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[suppliers] ADD  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__suppliers__creat__00750D23]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[suppliers] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tenant_subdomains]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tenant_subdomains](
	[tenant_subdomain_id] [int] IDENTITY(1,1) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[subdomain] [nvarchar](63) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[is_current] [bit] NOT NULL,
	[assigned_at] [datetime2](7) NOT NULL,
	[retired_at] [datetime2](7) NULL,
	[assigned_by] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[retired_reason] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_tenant_subdomains] PRIMARY KEY CLUSTERED 
(
	[tenant_subdomain_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_tenant_subdomains_subdomain] UNIQUE NONCLUSTERED 
(
	[subdomain] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tenant_subdomains]') AND name = N'IX_tenant_subdomains_lookup')
CREATE NONCLUSTERED INDEX [IX_tenant_subdomains_lookup] ON [dbo].[tenant_subdomains]
(
	[subdomain] ASC
)
INCLUDE([tenant_id],[is_current]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tenant_subdomains]') AND name = N'UX_tenant_subdomains_one_current')
CREATE UNIQUE NONCLUSTERED INDEX [UX_tenant_subdomains_one_current] ON [dbo].[tenant_subdomains]
(
	[tenant_id] ASC
)
WHERE ([is_current]=(1))
WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_tenant_subdomains_current]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[tenant_subdomains] ADD  CONSTRAINT [DF_tenant_subdomains_current]  DEFAULT ((1)) FOR [is_current]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_tenant_subdomains_assigned]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[tenant_subdomains] ADD  CONSTRAINT [DF_tenant_subdomains_assigned]  DEFAULT (sysutcdatetime()) FOR [assigned_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_tenant_subdomains_format]') AND parent_object_id = OBJECT_ID(N'[dbo].[tenant_subdomains]'))
ALTER TABLE [dbo].[tenant_subdomains]  WITH CHECK ADD  CONSTRAINT [CK_tenant_subdomains_format] CHECK  ((len([subdomain])>=(3) AND NOT ([subdomain]) collate Latin1_General_BIN2 like '%[^a-z0-9-]%' AND NOT ([subdomain]) collate Latin1_General_BIN2 like '-%' AND NOT ([subdomain]) collate Latin1_General_BIN2 like '%-'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_tenant_subdomains_format]') AND parent_object_id = OBJECT_ID(N'[dbo].[tenant_subdomains]'))
ALTER TABLE [dbo].[tenant_subdomains] CHECK CONSTRAINT [CK_tenant_subdomains_format]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tenants]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tenants](
	[tenant_id] [int] IDENTITY(1,1) NOT NULL,
	[tenant_name] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[subdomain] [nvarchar](63) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[legal_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[contact_email] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[contact_phone] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[bill_number_prefix] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[is_deleted] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[status] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[status_changed_at] [datetime2](7) NULL,
	[status_reason] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[plan_id] [int] NULL,
	[plan_started_at] [datetime2](7) NULL,
	[isolation_mode] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[time_zone] [nvarchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_tenants] PRIMARY KEY CLUSTERED 
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_tenants_name] UNIQUE NONCLUSTERED 
(
	[tenant_name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_tenants_subdomain] UNIQUE NONCLUSTERED 
(
	[subdomain] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tenants]') AND name = N'IX_tenants_plan')
CREATE NONCLUSTERED INDEX [IX_tenants_plan] ON [dbo].[tenants]
(
	[plan_id] ASC
)
INCLUDE([tenant_name],[status]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tenants]') AND name = N'IX_tenants_status')
CREATE NONCLUSTERED INDEX [IX_tenants_status] ON [dbo].[tenants]
(
	[status] ASC
)
INCLUDE([tenant_name],[subdomain]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_tenants_deleted]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[tenants] ADD  CONSTRAINT [DF_tenants_deleted]  DEFAULT ((0)) FOR [is_deleted]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_tenants_created]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[tenants] ADD  CONSTRAINT [DF_tenants_created]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_tenants_status]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[tenants] ADD  CONSTRAINT [DF_tenants_status]  DEFAULT (N'Pending') FOR [status]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_tenants_isolation_mode]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[tenants] ADD  CONSTRAINT [DF_tenants_isolation_mode]  DEFAULT (N'Shared') FOR [isolation_mode]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_tenants_time_zone]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[tenants] ADD  CONSTRAINT [DF_tenants_time_zone]  DEFAULT (N'Asia/Kolkata') FOR [time_zone]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_tenants_isolation_mode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tenants]'))
ALTER TABLE [dbo].[tenants]  WITH CHECK ADD  CONSTRAINT [CK_tenants_isolation_mode] CHECK  (([isolation_mode]=N'DedicatedDatabase' OR [isolation_mode]=N'Shared'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_tenants_isolation_mode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tenants]'))
ALTER TABLE [dbo].[tenants] CHECK CONSTRAINT [CK_tenants_isolation_mode]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_tenants_status]') AND parent_object_id = OBJECT_ID(N'[dbo].[tenants]'))
ALTER TABLE [dbo].[tenants]  WITH CHECK ADD  CONSTRAINT [CK_tenants_status] CHECK  (([status]=N'Deactivated' OR [status]=N'Suspended' OR [status]=N'Active' OR [status]=N'Pending'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_tenants_status]') AND parent_object_id = OBJECT_ID(N'[dbo].[tenants]'))
ALTER TABLE [dbo].[tenants] CHECK CONSTRAINT [CK_tenants_status]
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_tenants_subdomain]') AND parent_object_id = OBJECT_ID(N'[dbo].[tenants]'))
ALTER TABLE [dbo].[tenants]  WITH NOCHECK ADD  CONSTRAINT [CK_tenants_subdomain] CHECK  ((len([subdomain])>=(3) AND NOT ([subdomain]) collate Latin1_General_BIN2 like '%[^a-z0-9-]%' AND NOT ([subdomain]) collate Latin1_General_BIN2 like '-%' AND NOT ([subdomain]) collate Latin1_General_BIN2 like '%-'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_tenants_subdomain]') AND parent_object_id = OBJECT_ID(N'[dbo].[tenants]'))
ALTER TABLE [dbo].[tenants] CHECK CONSTRAINT [CK_tenants_subdomain]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[therapist_schedule]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[therapist_schedule](
	[schedule_id] [int] IDENTITY(1,1) NOT NULL,
	[therapist_id] [int] NOT NULL,
	[day_of_week] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[start_time] [time](5) NOT NULL,
	[end_time] [time](5) NOT NULL,
	[slot_duration_minutes] [int] NULL,
	[max_sessions_per_slot] [int] NULL,
	[is_active] [bit] NOT NULL,
	[effective_from] [date] NULL,
	[effective_to] [date] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
 CONSTRAINT [PK_therapist_schedule] PRIMARY KEY CLUSTERED 
(
	[schedule_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[therapist_schedule]') AND name = N'IX_therapist_schedule_branch')
CREATE NONCLUSTERED INDEX [IX_therapist_schedule_branch] ON [dbo].[therapist_schedule]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[therapist_schedule]') AND name = N'IX_therapist_schedule_tenant')
CREATE NONCLUSTERED INDEX [IX_therapist_schedule_tenant] ON [dbo].[therapist_schedule]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[therapist_schedule]') AND name = N'IX_therapist_schedule_therapist')
CREATE NONCLUSTERED INDEX [IX_therapist_schedule_therapist] ON [dbo].[therapist_schedule]
(
	[therapist_id] ASC,
	[is_active] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_therapist_schedule_duration]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[therapist_schedule] ADD  CONSTRAINT [DF_therapist_schedule_duration]  DEFAULT ((60)) FOR [slot_duration_minutes]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_therapist_schedule_capacity]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[therapist_schedule] ADD  CONSTRAINT [DF_therapist_schedule_capacity]  DEFAULT ((1)) FOR [max_sessions_per_slot]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_therapist_schedule_active]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[therapist_schedule] ADD  CONSTRAINT [DF_therapist_schedule_active]  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_therapist_schedule_day]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_schedule]'))
ALTER TABLE [dbo].[therapist_schedule]  WITH CHECK ADD  CONSTRAINT [CK_therapist_schedule_day] CHECK  (([day_of_week]='Sunday' OR [day_of_week]='Saturday' OR [day_of_week]='Friday' OR [day_of_week]='Thursday' OR [day_of_week]='Wednesday' OR [day_of_week]='Tuesday' OR [day_of_week]='Monday'))
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK_therapist_schedule_day]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_schedule]'))
ALTER TABLE [dbo].[therapist_schedule] CHECK CONSTRAINT [CK_therapist_schedule_day]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[therapist_slots]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[therapist_slots](
	[slot_id] [int] IDENTITY(1,1) NOT NULL,
	[therapist_id] [int] NOT NULL,
	[slot_date] [date] NOT NULL,
	[slot_time] [time](5) NOT NULL,
	[is_available] [bit] NOT NULL,
	[is_blocked] [bit] NOT NULL,
	[block_reason] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
 CONSTRAINT [PK_therapist_slots] PRIMARY KEY CLUSTERED 
(
	[slot_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_therapist_slots_therapist_id_slot_date_slot_time] UNIQUE NONCLUSTERED 
(
	[branch_id] ASC,
	[therapist_id] ASC,
	[slot_date] ASC,
	[slot_time] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[therapist_slots]') AND name = N'IX_therapist_slots_branch')
CREATE NONCLUSTERED INDEX [IX_therapist_slots_branch] ON [dbo].[therapist_slots]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[therapist_slots]') AND name = N'IX_therapist_slots_date')
CREATE NONCLUSTERED INDEX [IX_therapist_slots_date] ON [dbo].[therapist_slots]
(
	[slot_date] ASC,
	[therapist_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[therapist_slots]') AND name = N'IX_therapist_slots_tenant')
CREATE NONCLUSTERED INDEX [IX_therapist_slots_tenant] ON [dbo].[therapist_slots]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_therapist_slots_available]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[therapist_slots] ADD  CONSTRAINT [DF_therapist_slots_available]  DEFAULT ((1)) FOR [is_available]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_therapist_slots_blocked]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[therapist_slots] ADD  CONSTRAINT [DF_therapist_slots_blocked]  DEFAULT ((0)) FOR [is_blocked]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[urinary_habits]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[urinary_habits](
	[urine_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_id] [int] NOT NULL,
	[encounter_id] [int] NOT NULL,
	[day_frequency] [int] NULL,
	[night_frequency] [int] NULL,
	[color] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[odor] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[clarity] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[scalding] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[burning_sensation] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[urgency] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[hesitancy] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sediment] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[other_complaints] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[urine_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[urinary_habits]') AND name = N'IX_urinary_habits_branch')
CREATE NONCLUSTERED INDEX [IX_urinary_habits_branch] ON [dbo].[urinary_habits]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[urinary_habits]') AND name = N'IX_urinary_habits_encounter')
CREATE NONCLUSTERED INDEX [IX_urinary_habits_encounter] ON [dbo].[urinary_habits]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[urinary_habits]') AND name = N'IX_urinary_habits_tenant')
CREATE NONCLUSTERED INDEX [IX_urinary_habits_tenant] ON [dbo].[urinary_habits]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__urinary_h__creat__4E53A1AA]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[urinary_habits] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__urinary_h__updat__4F47C5E3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[urinary_habits] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__urinary_h__burni__4A8310C6]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits]  WITH CHECK ADD CHECK  (([burning_sensation]=N'No' OR [burning_sensation]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__urinary_h__clari__489AC854]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits]  WITH CHECK ADD CHECK  (([clarity]=N'Turbid' OR [clarity]=N'Cloudy' OR [clarity]=N'Clear'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__urinary_h__hesit__4C6B5938]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits]  WITH CHECK ADD CHECK  (([hesitancy]=N'No' OR [hesitancy]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__urinary_h__scald__498EEC8D]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits]  WITH CHECK ADD CHECK  (([scalding]=N'No' OR [scalding]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__urinary_h__sedim__4D5F7D71]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits]  WITH CHECK ADD CHECK  (([sediment]=N'No' OR [sediment]=N'Yes'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__urinary_h__urgen__4B7734FF]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits]  WITH CHECK ADD CHECK  (([urgency]=N'No' OR [urgency]=N'Yes'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_branches]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_branches](
	[user_branch_id] [int] IDENTITY(1,1) NOT NULL,
	[tenant_id] [int] NOT NULL,
	[user_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
	[is_default] [bit] NOT NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NULL,
 CONSTRAINT [PK_user_branches] PRIMARY KEY CLUSTERED 
(
	[user_branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_user_branches_user_branch] UNIQUE NONCLUSTERED 
(
	[user_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_branches]') AND name = N'IX_user_branches_user')
CREATE NONCLUSTERED INDEX [IX_user_branches_user] ON [dbo].[user_branches]
(
	[user_id] ASC,
	[is_active] ASC,
	[is_deleted] ASC
)
INCLUDE([branch_id],[is_default]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_user_branches_is_default]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[user_branches] ADD  CONSTRAINT [DF_user_branches_is_default]  DEFAULT ((0)) FOR [is_default]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_user_branches_is_active]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[user_branches] ADD  CONSTRAINT [DF_user_branches_is_active]  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_user_branches_is_deleted]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[user_branches] ADD  CONSTRAINT [DF_user_branches_is_deleted]  DEFAULT ((0)) FOR [is_deleted]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_user_branches_created_at]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[user_branches] ADD  CONSTRAINT [DF_user_branches_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_roles]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_roles](
	[user_role_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[role_id] [int] NOT NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[tenant_id] [int] NOT NULL,
 CONSTRAINT [PK_user_roles] PRIMARY KEY CLUSTERED 
(
	[user_role_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_user_roles] UNIQUE NONCLUSTERED 
(
	[user_id] ASC,
	[role_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_roles]') AND name = N'IX_user_roles_tenant')
CREATE NONCLUSTERED INDEX [IX_user_roles_tenant] ON [dbo].[user_roles]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_user_roles_created]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[user_roles] ADD  CONSTRAINT [DF_user_roles_created]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_user_roles_active]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[user_roles] ADD  CONSTRAINT [DF_user_roles_active]  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_user_roles_deleted]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[user_roles] ADD  CONSTRAINT [DF_user_roles_deleted]  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[users]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[users](
	[user_id] [int] IDENTITY(1,1) NOT NULL,
	[username] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[email] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[password_hash] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[first_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[last_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[created_by] [int] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime2](7) NULL,
	[is_active] [bit] NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[last_login] [datetime2](7) NULL,
	[staff_id] [int] NULL,
	[tenant_id] [int] NOT NULL,
 CONSTRAINT [PK_users] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_users_email] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[email] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF),
 CONSTRAINT [UQ_users_username] UNIQUE NONCLUSTERED 
(
	[tenant_id] ASC,
	[username] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[users]') AND name = N'IX_users_tenant')
CREATE NONCLUSTERED INDEX [IX_users_tenant] ON [dbo].[users]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_users_created]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [DF_users_created]  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_users_active]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [DF_users_active]  DEFAULT ((1)) FOR [is_active]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_users_deleted]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [DF_users_deleted]  DEFAULT ((0)) FOR [is_deleted]
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[visit_complaints]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[visit_complaints](
	[complaint_id] [int] IDENTITY(1,1) NOT NULL,
	[encounter_id] [int] NOT NULL,
	[patient_id] [int] NOT NULL,
	[symptoms_text] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[complaint_text] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[duration] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[physical_feelings] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[non_physical_feelings] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[severity] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[chronicity] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[aggravating_factors] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[relieving_factors] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[additional_notes] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[recorded_at] [datetime2](0) NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[complaint_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[visit_complaints]') AND name = N'IX_visit_complaints_branch')
CREATE NONCLUSTERED INDEX [IX_visit_complaints_branch] ON [dbo].[visit_complaints]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[visit_complaints]') AND name = N'IX_visit_complaints_encounter')
CREATE NONCLUSTERED INDEX [IX_visit_complaints_encounter] ON [dbo].[visit_complaints]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[visit_complaints]') AND name = N'IX_visit_complaints_tenant')
CREATE NONCLUSTERED INDEX [IX_visit_complaints_tenant] ON [dbo].[visit_complaints]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__visit_com__recor__1F98B2C1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[visit_complaints] ADD  DEFAULT (sysutcdatetime()) FOR [recorded_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__visit_com__creat__208CD6FA]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[visit_complaints] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__visit_com__updat__2180FB33]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[visit_complaints] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__visit_com__chron__1EA48E88]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_complaints]'))
ALTER TABLE [dbo].[visit_complaints]  WITH CHECK ADD CHECK  (([chronicity]=N'Subacute' OR [chronicity]=N'Chronic' OR [chronicity]=N'Acute'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[dbo].[CK__visit_com__sever__1DB06A4F]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_complaints]'))
ALTER TABLE [dbo].[visit_complaints]  WITH CHECK ADD CHECK  (([severity]=N'Severe' OR [severity]=N'Moderate' OR [severity]=N'Mild'))
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[visit_vitals]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[visit_vitals](
	[vital_id] [int] IDENTITY(1,1) NOT NULL,
	[encounter_id] [int] NOT NULL,
	[patient_id] [int] NOT NULL,
	[height] [decimal](5, 2) NULL,
	[weight] [decimal](5, 2) NULL,
	[bmi] [decimal](4, 2) NULL,
	[temperature] [decimal](4, 2) NULL,
	[pulse_rate] [int] NULL,
	[blood_pressure_systolic] [int] NULL,
	[blood_pressure_diastolic] [int] NULL,
	[respiratory_rate] [int] NULL,
	[oxygen_saturation] [decimal](5, 2) NULL,
	[recorded_at] [datetime2](0) NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](7) NULL,
	[created_by] [int] NULL,
	[updated_by] [int] NULL,
	[tenant_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[vital_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[visit_vitals]') AND name = N'IX_visit_vitals_branch')
CREATE NONCLUSTERED INDEX [IX_visit_vitals_branch] ON [dbo].[visit_vitals]
(
	[tenant_id] ASC,
	[branch_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[visit_vitals]') AND name = N'IX_visit_vitals_encounter')
CREATE NONCLUSTERED INDEX [IX_visit_vitals_encounter] ON [dbo].[visit_vitals]
(
	[encounter_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[visit_vitals]') AND name = N'IX_visit_vitals_tenant')
CREATE NONCLUSTERED INDEX [IX_visit_vitals_tenant] ON [dbo].[visit_vitals]
(
	[tenant_id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__visit_vit__recor__17036CC0]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[visit_vitals] ADD  DEFAULT (sysutcdatetime()) FOR [recorded_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__visit_vit__creat__17F790F9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[visit_vitals] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
END

GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__visit_vit__updat__18EBB532]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[visit_vitals] ADD  DEFAULT (sysutcdatetime()) FOR [updated_at]
END

GO

------------------------------------------------------------------ foreign keys

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__access_gr__acces__664B26CC]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_group_access_levels]'))
ALTER TABLE [dbo].[access_group_access_levels]  WITH CHECK ADD FOREIGN KEY([access_group_id])
REFERENCES [dbo].[access_groups] ([access_group_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__access_gr__acces__673F4B05]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_group_access_levels]'))
ALTER TABLE [dbo].[access_group_access_levels]  WITH CHECK ADD FOREIGN KEY([access_level_id])
REFERENCES [dbo].[access_levels] ([access_level_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_group_access_levels_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_group_access_levels]'))
ALTER TABLE [dbo].[access_group_access_levels]  WITH CHECK ADD  CONSTRAINT [FK_access_group_access_levels_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_group_access_levels_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_group_access_levels]'))
ALTER TABLE [dbo].[access_group_access_levels] CHECK CONSTRAINT [FK_access_group_access_levels_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_groups_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_groups]'))
ALTER TABLE [dbo].[access_groups]  WITH CHECK ADD  CONSTRAINT [FK_access_groups_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_groups_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_groups]'))
ALTER TABLE [dbo].[access_groups] CHECK CONSTRAINT [FK_access_groups_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__access_le__acces__6FD49106]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_menus]'))
ALTER TABLE [dbo].[access_level_menus]  WITH CHECK ADD FOREIGN KEY([access_level_id])
REFERENCES [dbo].[access_levels] ([access_level_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__access_le__menu___70C8B53F]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_menus]'))
ALTER TABLE [dbo].[access_level_menus]  WITH CHECK ADD FOREIGN KEY([menu_id])
REFERENCES [dbo].[menus] ([menu_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_level_menus_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_menus]'))
ALTER TABLE [dbo].[access_level_menus]  WITH CHECK ADD  CONSTRAINT [FK_access_level_menus_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_level_menus_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_menus]'))
ALTER TABLE [dbo].[access_level_menus] CHECK CONSTRAINT [FK_access_level_menus_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__access_le__acces__7C3A67EB]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_screens]'))
ALTER TABLE [dbo].[access_level_screens]  WITH CHECK ADD FOREIGN KEY([access_level_id])
REFERENCES [dbo].[access_levels] ([access_level_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__access_le__scree__7D2E8C24]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_screens]'))
ALTER TABLE [dbo].[access_level_screens]  WITH CHECK ADD FOREIGN KEY([screen_id])
REFERENCES [dbo].[screens] ([screen_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_level_screens_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_screens]'))
ALTER TABLE [dbo].[access_level_screens]  WITH CHECK ADD  CONSTRAINT [FK_access_level_screens_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_level_screens_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_screens]'))
ALTER TABLE [dbo].[access_level_screens] CHECK CONSTRAINT [FK_access_level_screens_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__access_le__acces__15FA39EE]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_section_fields]'))
ALTER TABLE [dbo].[access_level_section_fields]  WITH CHECK ADD FOREIGN KEY([access_level_id])
REFERENCES [dbo].[access_levels] ([access_level_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__access_le__secti__16EE5E27]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_section_fields]'))
ALTER TABLE [dbo].[access_level_section_fields]  WITH CHECK ADD FOREIGN KEY([section_field_id])
REFERENCES [dbo].[section_fields] ([section_field_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_level_section_fields_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_section_fields]'))
ALTER TABLE [dbo].[access_level_section_fields]  WITH CHECK ADD  CONSTRAINT [FK_access_level_section_fields_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_level_section_fields_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_section_fields]'))
ALTER TABLE [dbo].[access_level_section_fields] CHECK CONSTRAINT [FK_access_level_section_fields_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__access_le__acces__08A03ED0]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_sections]'))
ALTER TABLE [dbo].[access_level_sections]  WITH CHECK ADD FOREIGN KEY([access_level_id])
REFERENCES [dbo].[access_levels] ([access_level_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__access_le__secti__09946309]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_sections]'))
ALTER TABLE [dbo].[access_level_sections]  WITH CHECK ADD FOREIGN KEY([section_id])
REFERENCES [dbo].[sections] ([section_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_level_sections_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_sections]'))
ALTER TABLE [dbo].[access_level_sections]  WITH CHECK ADD  CONSTRAINT [FK_access_level_sections_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_level_sections_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_level_sections]'))
ALTER TABLE [dbo].[access_level_sections] CHECK CONSTRAINT [FK_access_level_sections_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_levels_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_levels]'))
ALTER TABLE [dbo].[access_levels]  WITH CHECK ADD  CONSTRAINT [FK_access_levels_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_access_levels_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[access_levels]'))
ALTER TABLE [dbo].[access_levels] CHECK CONSTRAINT [FK_access_levels_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_addiction_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[addictions]'))
ALTER TABLE [dbo].[addictions]  WITH CHECK ADD  CONSTRAINT [FK_addiction_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_addiction_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[addictions]'))
ALTER TABLE [dbo].[addictions] CHECK CONSTRAINT [FK_addiction_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_addictions_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[addictions]'))
ALTER TABLE [dbo].[addictions]  WITH CHECK ADD  CONSTRAINT [FK_addictions_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_addictions_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[addictions]'))
ALTER TABLE [dbo].[addictions] CHECK CONSTRAINT [FK_addictions_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_allergies_patients]') AND parent_object_id = OBJECT_ID(N'[dbo].[allergies]'))
ALTER TABLE [dbo].[allergies]  WITH CHECK ADD  CONSTRAINT [FK_allergies_patients] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_allergies_patients]') AND parent_object_id = OBJECT_ID(N'[dbo].[allergies]'))
ALTER TABLE [dbo].[allergies] CHECK CONSTRAINT [FK_allergies_patients]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_allergies_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[allergies]'))
ALTER TABLE [dbo].[allergies]  WITH CHECK ADD  CONSTRAINT [FK_allergies_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_allergies_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[allergies]'))
ALTER TABLE [dbo].[allergies] CHECK CONSTRAINT [FK_allergies_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ah_appointment]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_history]'))
ALTER TABLE [dbo].[appointment_history]  WITH CHECK ADD  CONSTRAINT [FK_ah_appointment] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([appointment_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ah_appointment]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_history]'))
ALTER TABLE [dbo].[appointment_history] CHECK CONSTRAINT [FK_ah_appointment]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_history_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_history]'))
ALTER TABLE [dbo].[appointment_history]  WITH CHECK ADD  CONSTRAINT [FK_appointment_history_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_history_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_history]'))
ALTER TABLE [dbo].[appointment_history] CHECK CONSTRAINT [FK_appointment_history_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_history_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_history]'))
ALTER TABLE [dbo].[appointment_history]  WITH CHECK ADD  CONSTRAINT [FK_appointment_history_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_history_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_history]'))
ALTER TABLE [dbo].[appointment_history] CHECK CONSTRAINT [FK_appointment_history_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_reminders_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_reminders]'))
ALTER TABLE [dbo].[appointment_reminders]  WITH CHECK ADD  CONSTRAINT [FK_appointment_reminders_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_reminders_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_reminders]'))
ALTER TABLE [dbo].[appointment_reminders] CHECK CONSTRAINT [FK_appointment_reminders_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_reminders_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_reminders]'))
ALTER TABLE [dbo].[appointment_reminders]  WITH CHECK ADD  CONSTRAINT [FK_appointment_reminders_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_reminders_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_reminders]'))
ALTER TABLE [dbo].[appointment_reminders] CHECK CONSTRAINT [FK_appointment_reminders_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ar_appointment]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_reminders]'))
ALTER TABLE [dbo].[appointment_reminders]  WITH CHECK ADD  CONSTRAINT [FK_ar_appointment] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([appointment_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ar_appointment]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_reminders]'))
ALTER TABLE [dbo].[appointment_reminders] CHECK CONSTRAINT [FK_ar_appointment]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_slots_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_slots]'))
ALTER TABLE [dbo].[appointment_slots]  WITH CHECK ADD  CONSTRAINT [FK_appointment_slots_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_slots_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_slots]'))
ALTER TABLE [dbo].[appointment_slots] CHECK CONSTRAINT [FK_appointment_slots_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_slots_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_slots]'))
ALTER TABLE [dbo].[appointment_slots]  WITH CHECK ADD  CONSTRAINT [FK_appointment_slots_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_slots_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_slots]'))
ALTER TABLE [dbo].[appointment_slots] CHECK CONSTRAINT [FK_appointment_slots_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_as_doctor]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_slots]'))
ALTER TABLE [dbo].[appointment_slots]  WITH CHECK ADD  CONSTRAINT [FK_as_doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([doctor_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_as_doctor]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_slots]'))
ALTER TABLE [dbo].[appointment_slots] CHECK CONSTRAINT [FK_as_doctor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapies_appointment]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapies]'))
ALTER TABLE [dbo].[appointment_therapies]  WITH CHECK ADD  CONSTRAINT [FK_appointment_therapies_appointment] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([appointment_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapies_appointment]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapies]'))
ALTER TABLE [dbo].[appointment_therapies] CHECK CONSTRAINT [FK_appointment_therapies_appointment]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapies_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapies]'))
ALTER TABLE [dbo].[appointment_therapies]  WITH CHECK ADD  CONSTRAINT [FK_appointment_therapies_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapies_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapies]'))
ALTER TABLE [dbo].[appointment_therapies] CHECK CONSTRAINT [FK_appointment_therapies_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapies_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapies]'))
ALTER TABLE [dbo].[appointment_therapies]  WITH CHECK ADD  CONSTRAINT [FK_appointment_therapies_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapies_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapies]'))
ALTER TABLE [dbo].[appointment_therapies] CHECK CONSTRAINT [FK_appointment_therapies_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapies_therapy]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapies]'))
ALTER TABLE [dbo].[appointment_therapies]  WITH CHECK ADD  CONSTRAINT [FK_appointment_therapies_therapy] FOREIGN KEY([therapy_id])
REFERENCES [dbo].[panchkarma_therapies] ([therapy_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapies_therapy]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapies]'))
ALTER TABLE [dbo].[appointment_therapies] CHECK CONSTRAINT [FK_appointment_therapies_therapy]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapists_appointment]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapists]'))
ALTER TABLE [dbo].[appointment_therapists]  WITH CHECK ADD  CONSTRAINT [FK_appointment_therapists_appointment] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([appointment_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapists_appointment]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapists]'))
ALTER TABLE [dbo].[appointment_therapists] CHECK CONSTRAINT [FK_appointment_therapists_appointment]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapists_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapists]'))
ALTER TABLE [dbo].[appointment_therapists]  WITH CHECK ADD  CONSTRAINT [FK_appointment_therapists_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapists_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapists]'))
ALTER TABLE [dbo].[appointment_therapists] CHECK CONSTRAINT [FK_appointment_therapists_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapists_staff]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapists]'))
ALTER TABLE [dbo].[appointment_therapists]  WITH CHECK ADD  CONSTRAINT [FK_appointment_therapists_staff] FOREIGN KEY([therapist_id])
REFERENCES [dbo].[staff] ([staff_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapists_staff]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapists]'))
ALTER TABLE [dbo].[appointment_therapists] CHECK CONSTRAINT [FK_appointment_therapists_staff]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapists_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapists]'))
ALTER TABLE [dbo].[appointment_therapists]  WITH CHECK ADD  CONSTRAINT [FK_appointment_therapists_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointment_therapists_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointment_therapists]'))
ALTER TABLE [dbo].[appointment_therapists] CHECK CONSTRAINT [FK_appointment_therapists_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointments_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [FK_appointments_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointments_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [FK_appointments_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointments_room]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [FK_appointments_room] FOREIGN KEY([room_id])
REFERENCES [dbo].[panchkarma_rooms] ([room_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointments_room]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [FK_appointments_room]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointments_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [FK_appointments_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointments_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [FK_appointments_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointments_therapist]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [FK_appointments_therapist] FOREIGN KEY([therapist_id])
REFERENCES [dbo].[staff] ([staff_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointments_therapist]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [FK_appointments_therapist]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointments_therapy]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [FK_appointments_therapy] FOREIGN KEY([therapy_id])
REFERENCES [dbo].[panchkarma_therapies] ([therapy_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_appointments_therapy]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [FK_appointments_therapy]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_apt_doctor]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [FK_apt_doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([doctor_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_apt_doctor]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [FK_apt_doctor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_apt_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments]  WITH CHECK ADD  CONSTRAINT [FK_apt_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_apt_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[appointments]'))
ALTER TABLE [dbo].[appointments] CHECK CONSTRAINT [FK_apt_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ashta_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[ashtavidha_pariksha]'))
ALTER TABLE [dbo].[ashtavidha_pariksha]  WITH CHECK ADD  CONSTRAINT [FK_ashta_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ashta_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[ashtavidha_pariksha]'))
ALTER TABLE [dbo].[ashtavidha_pariksha] CHECK CONSTRAINT [FK_ashta_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ashta_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[ashtavidha_pariksha]'))
ALTER TABLE [dbo].[ashtavidha_pariksha]  WITH CHECK ADD  CONSTRAINT [FK_ashta_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ashta_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[ashtavidha_pariksha]'))
ALTER TABLE [dbo].[ashtavidha_pariksha] CHECK CONSTRAINT [FK_ashta_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ashtavidha_pariksha_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[ashtavidha_pariksha]'))
ALTER TABLE [dbo].[ashtavidha_pariksha]  WITH CHECK ADD  CONSTRAINT [FK_ashtavidha_pariksha_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ashtavidha_pariksha_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[ashtavidha_pariksha]'))
ALTER TABLE [dbo].[ashtavidha_pariksha] CHECK CONSTRAINT [FK_ashtavidha_pariksha_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ashtavidha_pariksha_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[ashtavidha_pariksha]'))
ALTER TABLE [dbo].[ashtavidha_pariksha]  WITH CHECK ADD  CONSTRAINT [FK_ashtavidha_pariksha_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ashtavidha_pariksha_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[ashtavidha_pariksha]'))
ALTER TABLE [dbo].[ashtavidha_pariksha] CHECK CONSTRAINT [FK_ashtavidha_pariksha_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_audit_changed_by]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log]  WITH CHECK ADD  CONSTRAINT [FK_audit_changed_by] FOREIGN KEY([changed_by])
REFERENCES [dbo].[staff] ([staff_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_audit_changed_by]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log] CHECK CONSTRAINT [FK_audit_changed_by]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_audit_log_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log]  WITH CHECK ADD  CONSTRAINT [FK_audit_log_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_audit_log_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log] CHECK CONSTRAINT [FK_audit_log_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_audit_log_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log]  WITH CHECK ADD  CONSTRAINT [FK_audit_log_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_audit_log_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log] CHECK CONSTRAINT [FK_audit_log_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_audit_log_user]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log]  WITH NOCHECK ADD  CONSTRAINT [FK_audit_log_user] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([user_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_audit_log_user]') AND parent_object_id = OBJECT_ID(N'[dbo].[audit_log]'))
ALTER TABLE [dbo].[audit_log] CHECK CONSTRAINT [FK_audit_log_user]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ayur_exam_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[ayurvedic_examination]'))
ALTER TABLE [dbo].[ayurvedic_examination]  WITH CHECK ADD  CONSTRAINT [FK_ayur_exam_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ayur_exam_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[ayurvedic_examination]'))
ALTER TABLE [dbo].[ayurvedic_examination] CHECK CONSTRAINT [FK_ayur_exam_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ayur_exam_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[ayurvedic_examination]'))
ALTER TABLE [dbo].[ayurvedic_examination]  WITH CHECK ADD  CONSTRAINT [FK_ayur_exam_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ayur_exam_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[ayurvedic_examination]'))
ALTER TABLE [dbo].[ayurvedic_examination] CHECK CONSTRAINT [FK_ayur_exam_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ayurvedic_examination_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[ayurvedic_examination]'))
ALTER TABLE [dbo].[ayurvedic_examination]  WITH CHECK ADD  CONSTRAINT [FK_ayurvedic_examination_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ayurvedic_examination_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[ayurvedic_examination]'))
ALTER TABLE [dbo].[ayurvedic_examination] CHECK CONSTRAINT [FK_ayurvedic_examination_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ayurvedic_examination_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[ayurvedic_examination]'))
ALTER TABLE [dbo].[ayurvedic_examination]  WITH CHECK ADD  CONSTRAINT [FK_ayurvedic_examination_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ayurvedic_examination_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[ayurvedic_examination]'))
ALTER TABLE [dbo].[ayurvedic_examination] CHECK CONSTRAINT [FK_ayurvedic_examination_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_item_bill]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items]  WITH CHECK ADD  CONSTRAINT [FK_bill_item_bill] FOREIGN KEY([bill_id])
REFERENCES [dbo].[bills] ([bill_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_item_bill]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items] CHECK CONSTRAINT [FK_bill_item_bill]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_item_medicine]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items]  WITH CHECK ADD  CONSTRAINT [FK_bill_item_medicine] FOREIGN KEY([medicine_id])
REFERENCES [dbo].[medicines_master] ([medicine_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_item_medicine]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items] CHECK CONSTRAINT [FK_bill_item_medicine]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_items_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items]  WITH CHECK ADD  CONSTRAINT [FK_bill_items_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_items_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items] CHECK CONSTRAINT [FK_bill_items_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_items_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items]  WITH CHECK ADD  CONSTRAINT [FK_bill_items_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_items_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[bill_items]'))
ALTER TABLE [dbo].[bill_items] CHECK CONSTRAINT [FK_bill_items_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_appointment]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills]  WITH CHECK ADD  CONSTRAINT [FK_bill_appointment] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([appointment_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_appointment]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills] CHECK CONSTRAINT [FK_bill_appointment]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills]  WITH CHECK ADD  CONSTRAINT [FK_bill_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills] CHECK CONSTRAINT [FK_bill_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills]  WITH CHECK ADD  CONSTRAINT [FK_bill_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bill_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills] CHECK CONSTRAINT [FK_bill_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bills_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills]  WITH CHECK ADD  CONSTRAINT [FK_bills_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bills_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills] CHECK CONSTRAINT [FK_bills_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bills_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills]  WITH CHECK ADD  CONSTRAINT [FK_bills_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bills_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[bills]'))
ALTER TABLE [dbo].[bills] CHECK CONSTRAINT [FK_bills_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bowel_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD  CONSTRAINT [FK_bowel_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bowel_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits] CHECK CONSTRAINT [FK_bowel_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bowel_habits_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD  CONSTRAINT [FK_bowel_habits_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bowel_habits_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits] CHECK CONSTRAINT [FK_bowel_habits_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bowel_habits_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD  CONSTRAINT [FK_bowel_habits_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bowel_habits_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits] CHECK CONSTRAINT [FK_bowel_habits_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bowel_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits]  WITH CHECK ADD  CONSTRAINT [FK_bowel_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_bowel_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[bowel_habits]'))
ALTER TABLE [dbo].[bowel_habits] CHECK CONSTRAINT [FK_bowel_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_branches_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[branches]'))
ALTER TABLE [dbo].[branches]  WITH CHECK ADD  CONSTRAINT [FK_branches_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_branches_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[branches]'))
ALTER TABLE [dbo].[branches] CHECK CONSTRAINT [FK_branches_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_current_medications_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[current_medications]'))
ALTER TABLE [dbo].[current_medications]  WITH CHECK ADD  CONSTRAINT [FK_current_medications_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_current_medications_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[current_medications]'))
ALTER TABLE [dbo].[current_medications] CHECK CONSTRAINT [FK_current_medications_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_medication_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[current_medications]'))
ALTER TABLE [dbo].[current_medications]  WITH CHECK ADD  CONSTRAINT [FK_medication_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_medication_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[current_medications]'))
ALTER TABLE [dbo].[current_medications] CHECK CONSTRAINT [FK_medication_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_daily_routine_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[daily_routine]'))
ALTER TABLE [dbo].[daily_routine]  WITH CHECK ADD  CONSTRAINT [FK_daily_routine_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_daily_routine_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[daily_routine]'))
ALTER TABLE [dbo].[daily_routine] CHECK CONSTRAINT [FK_daily_routine_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_daily_routine_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[daily_routine]'))
ALTER TABLE [dbo].[daily_routine]  WITH CHECK ADD  CONSTRAINT [FK_daily_routine_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_daily_routine_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[daily_routine]'))
ALTER TABLE [dbo].[daily_routine] CHECK CONSTRAINT [FK_daily_routine_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_routine_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[daily_routine]'))
ALTER TABLE [dbo].[daily_routine]  WITH CHECK ADD  CONSTRAINT [FK_routine_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_routine_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[daily_routine]'))
ALTER TABLE [dbo].[daily_routine] CHECK CONSTRAINT [FK_routine_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_routine_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[daily_routine]'))
ALTER TABLE [dbo].[daily_routine]  WITH CHECK ADD  CONSTRAINT [FK_routine_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_routine_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[daily_routine]'))
ALTER TABLE [dbo].[daily_routine] CHECK CONSTRAINT [FK_routine_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_diet_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits]  WITH CHECK ADD  CONSTRAINT [FK_diet_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_diet_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits] CHECK CONSTRAINT [FK_diet_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_diet_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits]  WITH CHECK ADD  CONSTRAINT [FK_diet_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_diet_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits] CHECK CONSTRAINT [FK_diet_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dietary_habits_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits]  WITH CHECK ADD  CONSTRAINT [FK_dietary_habits_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dietary_habits_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits] CHECK CONSTRAINT [FK_dietary_habits_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dietary_habits_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits]  WITH CHECK ADD  CONSTRAINT [FK_dietary_habits_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dietary_habits_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[dietary_habits]'))
ALTER TABLE [dbo].[dietary_habits] CHECK CONSTRAINT [FK_dietary_habits_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_doctor_schedule_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule]  WITH CHECK ADD  CONSTRAINT [FK_doctor_schedule_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_doctor_schedule_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule] CHECK CONSTRAINT [FK_doctor_schedule_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_doctor_schedule_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule]  WITH CHECK ADD  CONSTRAINT [FK_doctor_schedule_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_doctor_schedule_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule] CHECK CONSTRAINT [FK_doctor_schedule_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ds_doctor]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule]  WITH CHECK ADD  CONSTRAINT [FK_ds_doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([doctor_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ds_doctor]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctor_schedule]'))
ALTER TABLE [dbo].[doctor_schedule] CHECK CONSTRAINT [FK_ds_doctor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_doctors_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctors]'))
ALTER TABLE [dbo].[doctors]  WITH CHECK ADD  CONSTRAINT [FK_doctors_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_doctors_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[doctors]'))
ALTER TABLE [dbo].[doctors] CHECK CONSTRAINT [FK_doctors_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_diagnosis_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]'))
ALTER TABLE [dbo].[encounter_diagnosis]  WITH CHECK ADD  CONSTRAINT [FK_diagnosis_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_diagnosis_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]'))
ALTER TABLE [dbo].[encounter_diagnosis] CHECK CONSTRAINT [FK_diagnosis_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_diagnosis_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]'))
ALTER TABLE [dbo].[encounter_diagnosis]  WITH CHECK ADD  CONSTRAINT [FK_diagnosis_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_diagnosis_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]'))
ALTER TABLE [dbo].[encounter_diagnosis] CHECK CONSTRAINT [FK_diagnosis_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_diagnosis_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]'))
ALTER TABLE [dbo].[encounter_diagnosis]  WITH CHECK ADD  CONSTRAINT [FK_encounter_diagnosis_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_diagnosis_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]'))
ALTER TABLE [dbo].[encounter_diagnosis] CHECK CONSTRAINT [FK_encounter_diagnosis_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_diagnosis_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]'))
ALTER TABLE [dbo].[encounter_diagnosis]  WITH CHECK ADD  CONSTRAINT [FK_encounter_diagnosis_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_diagnosis_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_diagnosis]'))
ALTER TABLE [dbo].[encounter_diagnosis] CHECK CONSTRAINT [FK_encounter_diagnosis_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_notes_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_notes]'))
ALTER TABLE [dbo].[encounter_notes]  WITH CHECK ADD  CONSTRAINT [FK_encounter_notes_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_notes_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_notes]'))
ALTER TABLE [dbo].[encounter_notes] CHECK CONSTRAINT [FK_encounter_notes_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_notes_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_notes]'))
ALTER TABLE [dbo].[encounter_notes]  WITH CHECK ADD  CONSTRAINT [FK_encounter_notes_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_notes_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_notes]'))
ALTER TABLE [dbo].[encounter_notes] CHECK CONSTRAINT [FK_encounter_notes_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_notes_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_notes]'))
ALTER TABLE [dbo].[encounter_notes]  WITH CHECK ADD  CONSTRAINT [FK_notes_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_notes_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_notes]'))
ALTER TABLE [dbo].[encounter_notes] CHECK CONSTRAINT [FK_notes_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_notes_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_notes]'))
ALTER TABLE [dbo].[encounter_notes]  WITH CHECK ADD  CONSTRAINT [FK_notes_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_notes_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_notes]'))
ALTER TABLE [dbo].[encounter_notes] CHECK CONSTRAINT [FK_notes_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_prescriptions_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]'))
ALTER TABLE [dbo].[encounter_prescriptions]  WITH CHECK ADD  CONSTRAINT [FK_encounter_prescriptions_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_prescriptions_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]'))
ALTER TABLE [dbo].[encounter_prescriptions] CHECK CONSTRAINT [FK_encounter_prescriptions_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_prescriptions_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]'))
ALTER TABLE [dbo].[encounter_prescriptions]  WITH CHECK ADD  CONSTRAINT [FK_encounter_prescriptions_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_prescriptions_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]'))
ALTER TABLE [dbo].[encounter_prescriptions] CHECK CONSTRAINT [FK_encounter_prescriptions_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ep_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]'))
ALTER TABLE [dbo].[encounter_prescriptions]  WITH CHECK ADD  CONSTRAINT [FK_ep_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ep_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]'))
ALTER TABLE [dbo].[encounter_prescriptions] CHECK CONSTRAINT [FK_ep_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ep_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]'))
ALTER TABLE [dbo].[encounter_prescriptions]  WITH CHECK ADD  CONSTRAINT [FK_ep_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ep_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_prescriptions]'))
ALTER TABLE [dbo].[encounter_prescriptions] CHECK CONSTRAINT [FK_ep_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_treatment_plan_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_treatment_plan]'))
ALTER TABLE [dbo].[encounter_treatment_plan]  WITH CHECK ADD  CONSTRAINT [FK_encounter_treatment_plan_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_treatment_plan_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_treatment_plan]'))
ALTER TABLE [dbo].[encounter_treatment_plan] CHECK CONSTRAINT [FK_encounter_treatment_plan_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_treatment_plan_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_treatment_plan]'))
ALTER TABLE [dbo].[encounter_treatment_plan]  WITH CHECK ADD  CONSTRAINT [FK_encounter_treatment_plan_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_treatment_plan_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_treatment_plan]'))
ALTER TABLE [dbo].[encounter_treatment_plan] CHECK CONSTRAINT [FK_encounter_treatment_plan_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_etp_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_treatment_plan]'))
ALTER TABLE [dbo].[encounter_treatment_plan]  WITH CHECK ADD  CONSTRAINT [FK_etp_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_etp_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_treatment_plan]'))
ALTER TABLE [dbo].[encounter_treatment_plan] CHECK CONSTRAINT [FK_etp_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_etp_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_treatment_plan]'))
ALTER TABLE [dbo].[encounter_treatment_plan]  WITH CHECK ADD  CONSTRAINT [FK_etp_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_etp_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[encounter_treatment_plan]'))
ALTER TABLE [dbo].[encounter_treatment_plan] CHECK CONSTRAINT [FK_etp_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_family_medical_history_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[family_medical_history]'))
ALTER TABLE [dbo].[family_medical_history]  WITH CHECK ADD  CONSTRAINT [FK_family_medical_history_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_family_medical_history_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[family_medical_history]'))
ALTER TABLE [dbo].[family_medical_history] CHECK CONSTRAINT [FK_family_medical_history_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_family_medical_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[family_medical_history]'))
ALTER TABLE [dbo].[family_medical_history]  WITH CHECK ADD  CONSTRAINT [FK_family_medical_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_family_medical_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[family_medical_history]'))
ALTER TABLE [dbo].[family_medical_history] CHECK CONSTRAINT [FK_family_medical_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_follow_up_schedule_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[follow_up_schedule]'))
ALTER TABLE [dbo].[follow_up_schedule]  WITH CHECK ADD  CONSTRAINT [FK_follow_up_schedule_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_follow_up_schedule_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[follow_up_schedule]'))
ALTER TABLE [dbo].[follow_up_schedule] CHECK CONSTRAINT [FK_follow_up_schedule_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_follow_up_schedule_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[follow_up_schedule]'))
ALTER TABLE [dbo].[follow_up_schedule]  WITH CHECK ADD  CONSTRAINT [FK_follow_up_schedule_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_follow_up_schedule_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[follow_up_schedule]'))
ALTER TABLE [dbo].[follow_up_schedule] CHECK CONSTRAINT [FK_follow_up_schedule_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_fus_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[follow_up_schedule]'))
ALTER TABLE [dbo].[follow_up_schedule]  WITH CHECK ADD  CONSTRAINT [FK_fus_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_fus_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[follow_up_schedule]'))
ALTER TABLE [dbo].[follow_up_schedule] CHECK CONSTRAINT [FK_fus_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_fus_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[follow_up_schedule]'))
ALTER TABLE [dbo].[follow_up_schedule]  WITH CHECK ADD  CONSTRAINT [FK_fus_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_fus_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[follow_up_schedule]'))
ALTER TABLE [dbo].[follow_up_schedule] CHECK CONSTRAINT [FK_fus_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_habbit_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[habbits]'))
ALTER TABLE [dbo].[habbits]  WITH CHECK ADD  CONSTRAINT [FK_habbit_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_habbit_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[habbits]'))
ALTER TABLE [dbo].[habbits] CHECK CONSTRAINT [FK_habbit_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_habbits_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[habbits]'))
ALTER TABLE [dbo].[habbits]  WITH CHECK ADD  CONSTRAINT [FK_habbits_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_habbits_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[habbits]'))
ALTER TABLE [dbo].[habbits] CHECK CONSTRAINT [FK_habbits_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_medicine]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory]  WITH CHECK ADD  CONSTRAINT [FK_inv_medicine] FOREIGN KEY([medicine_id])
REFERENCES [dbo].[medicines_master] ([medicine_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_medicine]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory] CHECK CONSTRAINT [FK_inv_medicine]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_supplier]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory]  WITH CHECK ADD  CONSTRAINT [FK_inv_supplier] FOREIGN KEY([supplier_id])
REFERENCES [dbo].[suppliers] ([supplier_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_supplier]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory] CHECK CONSTRAINT [FK_inv_supplier]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inventory_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory]  WITH CHECK ADD  CONSTRAINT [FK_inventory_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inventory_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory] CHECK CONSTRAINT [FK_inventory_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inventory_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory]  WITH CHECK ADD  CONSTRAINT [FK_inventory_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inventory_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[inventory]'))
ALTER TABLE [dbo].[inventory] CHECK CONSTRAINT [FK_inventory_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_file_report]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_report_files]'))
ALTER TABLE [dbo].[investigation_report_files]  WITH CHECK ADD  CONSTRAINT [FK_inv_file_report] FOREIGN KEY([report_id])
REFERENCES [dbo].[investigation_reports] ([report_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_file_report]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_report_files]'))
ALTER TABLE [dbo].[investigation_report_files] CHECK CONSTRAINT [FK_inv_file_report]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_investigation_report_files_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_report_files]'))
ALTER TABLE [dbo].[investigation_report_files]  WITH CHECK ADD  CONSTRAINT [FK_investigation_report_files_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_investigation_report_files_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_report_files]'))
ALTER TABLE [dbo].[investigation_report_files] CHECK CONSTRAINT [FK_investigation_report_files_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_investigation_report_files_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_report_files]'))
ALTER TABLE [dbo].[investigation_report_files]  WITH CHECK ADD  CONSTRAINT [FK_investigation_report_files_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_investigation_report_files_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_report_files]'))
ALTER TABLE [dbo].[investigation_report_files] CHECK CONSTRAINT [FK_investigation_report_files_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_report_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_reports]'))
ALTER TABLE [dbo].[investigation_reports]  WITH CHECK ADD  CONSTRAINT [FK_inv_report_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_report_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_reports]'))
ALTER TABLE [dbo].[investigation_reports] CHECK CONSTRAINT [FK_inv_report_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_report_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_reports]'))
ALTER TABLE [dbo].[investigation_reports]  WITH CHECK ADD  CONSTRAINT [FK_inv_report_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_report_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_reports]'))
ALTER TABLE [dbo].[investigation_reports] CHECK CONSTRAINT [FK_inv_report_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_report_staff]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_reports]'))
ALTER TABLE [dbo].[investigation_reports]  WITH CHECK ADD  CONSTRAINT [FK_inv_report_staff] FOREIGN KEY([reviewed_by])
REFERENCES [dbo].[staff] ([staff_id])
ON DELETE SET NULL
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_report_staff]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_reports]'))
ALTER TABLE [dbo].[investigation_reports] CHECK CONSTRAINT [FK_inv_report_staff]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_investigation_reports_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_reports]'))
ALTER TABLE [dbo].[investigation_reports]  WITH CHECK ADD  CONSTRAINT [FK_investigation_reports_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_investigation_reports_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_reports]'))
ALTER TABLE [dbo].[investigation_reports] CHECK CONSTRAINT [FK_investigation_reports_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_investigation_reports_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_reports]'))
ALTER TABLE [dbo].[investigation_reports]  WITH CHECK ADD  CONSTRAINT [FK_investigation_reports_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_investigation_reports_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigation_reports]'))
ALTER TABLE [dbo].[investigation_reports] CHECK CONSTRAINT [FK_investigation_reports_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigations]'))
ALTER TABLE [dbo].[investigations]  WITH CHECK ADD  CONSTRAINT [FK_inv_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigations]'))
ALTER TABLE [dbo].[investigations] CHECK CONSTRAINT [FK_inv_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigations]'))
ALTER TABLE [dbo].[investigations]  WITH CHECK ADD  CONSTRAINT [FK_inv_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_inv_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigations]'))
ALTER TABLE [dbo].[investigations] CHECK CONSTRAINT [FK_inv_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_investigations_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigations]'))
ALTER TABLE [dbo].[investigations]  WITH CHECK ADD  CONSTRAINT [FK_investigations_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_investigations_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigations]'))
ALTER TABLE [dbo].[investigations] CHECK CONSTRAINT [FK_investigations_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_investigations_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigations]'))
ALTER TABLE [dbo].[investigations]  WITH CHECK ADD  CONSTRAINT [FK_investigations_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_investigations_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[investigations]'))
ALTER TABLE [dbo].[investigations] CHECK CONSTRAINT [FK_investigations_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_medicines_master_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[medicines_master]'))
ALTER TABLE [dbo].[medicines_master]  WITH CHECK ADD  CONSTRAINT [FK_medicines_master_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_medicines_master_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[medicines_master]'))
ALTER TABLE [dbo].[medicines_master] CHECK CONSTRAINT [FK_medicines_master_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_mental_health_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD  CONSTRAINT [FK_mental_health_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_mental_health_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health] CHECK CONSTRAINT [FK_mental_health_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_mental_health_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD  CONSTRAINT [FK_mental_health_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_mental_health_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health] CHECK CONSTRAINT [FK_mental_health_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_mental_health_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD  CONSTRAINT [FK_mental_health_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_mental_health_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health] CHECK CONSTRAINT [FK_mental_health_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_mental_health_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health]  WITH CHECK ADD  CONSTRAINT [FK_mental_health_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_mental_health_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[mental_health]'))
ALTER TABLE [dbo].[mental_health] CHECK CONSTRAINT [FK_mental_health_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__menus__parent_me__44EA3301]') AND parent_object_id = OBJECT_ID(N'[dbo].[menus]'))
ALTER TABLE [dbo].[menus]  WITH CHECK ADD FOREIGN KEY([parent_menu_id])
REFERENCES [dbo].[menus] ([menu_id])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_nadi_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[nadi_pariksha]'))
ALTER TABLE [dbo].[nadi_pariksha]  WITH CHECK ADD  CONSTRAINT [FK_nadi_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_nadi_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[nadi_pariksha]'))
ALTER TABLE [dbo].[nadi_pariksha] CHECK CONSTRAINT [FK_nadi_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_nadi_pariksha_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[nadi_pariksha]'))
ALTER TABLE [dbo].[nadi_pariksha]  WITH CHECK ADD  CONSTRAINT [FK_nadi_pariksha_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_nadi_pariksha_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[nadi_pariksha]'))
ALTER TABLE [dbo].[nadi_pariksha] CHECK CONSTRAINT [FK_nadi_pariksha_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_nadi_pariksha_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[nadi_pariksha]'))
ALTER TABLE [dbo].[nadi_pariksha]  WITH CHECK ADD  CONSTRAINT [FK_nadi_pariksha_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_nadi_pariksha_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[nadi_pariksha]'))
ALTER TABLE [dbo].[nadi_pariksha] CHECK CONSTRAINT [FK_nadi_pariksha_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_nadi_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[nadi_pariksha]'))
ALTER TABLE [dbo].[nadi_pariksha]  WITH CHECK ADD  CONSTRAINT [FK_nadi_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_nadi_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[nadi_pariksha]'))
ALTER TABLE [dbo].[nadi_pariksha] CHECK CONSTRAINT [FK_nadi_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_number_series_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[number_series]'))
ALTER TABLE [dbo].[number_series]  WITH CHECK ADD  CONSTRAINT [FK_number_series_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_number_series_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[number_series]'))
ALTER TABLE [dbo].[number_series] CHECK CONSTRAINT [FK_number_series_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_procedures_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]'))
ALTER TABLE [dbo].[panchkarma_procedures]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_procedures_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_procedures_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]'))
ALTER TABLE [dbo].[panchkarma_procedures] CHECK CONSTRAINT [FK_panchkarma_procedures_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_procedures_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]'))
ALTER TABLE [dbo].[panchkarma_procedures]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_procedures_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_procedures_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]'))
ALTER TABLE [dbo].[panchkarma_procedures] CHECK CONSTRAINT [FK_panchkarma_procedures_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_procedures_therapy]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]'))
ALTER TABLE [dbo].[panchkarma_procedures]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_procedures_therapy] FOREIGN KEY([therapy_id])
REFERENCES [dbo].[panchkarma_therapies] ([therapy_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_procedures_therapy]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]'))
ALTER TABLE [dbo].[panchkarma_procedures] CHECK CONSTRAINT [FK_panchkarma_procedures_therapy]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_pkp_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]'))
ALTER TABLE [dbo].[panchkarma_procedures]  WITH CHECK ADD  CONSTRAINT [FK_pkp_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_pkp_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]'))
ALTER TABLE [dbo].[panchkarma_procedures] CHECK CONSTRAINT [FK_pkp_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_pkp_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]'))
ALTER TABLE [dbo].[panchkarma_procedures]  WITH CHECK ADD  CONSTRAINT [FK_pkp_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_pkp_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_procedures]'))
ALTER TABLE [dbo].[panchkarma_procedures] CHECK CONSTRAINT [FK_pkp_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_rooms_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_rooms]'))
ALTER TABLE [dbo].[panchkarma_rooms]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_rooms_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_rooms_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_rooms]'))
ALTER TABLE [dbo].[panchkarma_rooms] CHECK CONSTRAINT [FK_panchkarma_rooms_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_rooms_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_rooms]'))
ALTER TABLE [dbo].[panchkarma_rooms]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_rooms_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_rooms_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_rooms]'))
ALTER TABLE [dbo].[panchkarma_rooms] CHECK CONSTRAINT [FK_panchkarma_rooms_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_appointment]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_sessions_appointment] FOREIGN KEY([appointment_id])
REFERENCES [dbo].[appointments] ([appointment_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_appointment]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions] CHECK CONSTRAINT [FK_panchkarma_sessions_appointment]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_sessions_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions] CHECK CONSTRAINT [FK_panchkarma_sessions_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_doctor]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_sessions_doctor] FOREIGN KEY([doctor_id])
REFERENCES [dbo].[doctors] ([doctor_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_doctor]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions] CHECK CONSTRAINT [FK_panchkarma_sessions_doctor]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_sessions_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions] CHECK CONSTRAINT [FK_panchkarma_sessions_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_room]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_sessions_room] FOREIGN KEY([room_id])
REFERENCES [dbo].[panchkarma_rooms] ([room_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_room]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions] CHECK CONSTRAINT [FK_panchkarma_sessions_room]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_sessions_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions] CHECK CONSTRAINT [FK_panchkarma_sessions_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_therapist]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_sessions_therapist] FOREIGN KEY([therapist_id])
REFERENCES [dbo].[staff] ([staff_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_therapist]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions] CHECK CONSTRAINT [FK_panchkarma_sessions_therapist]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_therapy]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_sessions_therapy] FOREIGN KEY([therapy_id])
REFERENCES [dbo].[panchkarma_therapies] ([therapy_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_sessions_therapy]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_sessions]'))
ALTER TABLE [dbo].[panchkarma_sessions] CHECK CONSTRAINT [FK_panchkarma_sessions_therapy]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_therapies_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_therapies]'))
ALTER TABLE [dbo].[panchkarma_therapies]  WITH CHECK ADD  CONSTRAINT [FK_panchkarma_therapies_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_panchkarma_therapies_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[panchkarma_therapies]'))
ALTER TABLE [dbo].[panchkarma_therapies] CHECK CONSTRAINT [FK_panchkarma_therapies_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_past_medical_history_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[past_medical_history]'))
ALTER TABLE [dbo].[past_medical_history]  WITH CHECK ADD  CONSTRAINT [FK_past_medical_history_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_past_medical_history_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[past_medical_history]'))
ALTER TABLE [dbo].[past_medical_history] CHECK CONSTRAINT [FK_past_medical_history_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_past_medical_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[past_medical_history]'))
ALTER TABLE [dbo].[past_medical_history]  WITH CHECK ADD  CONSTRAINT [FK_past_medical_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_past_medical_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[past_medical_history]'))
ALTER TABLE [dbo].[past_medical_history] CHECK CONSTRAINT [FK_past_medical_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_encounters]'))
ALTER TABLE [dbo].[patient_encounters]  WITH CHECK ADD  CONSTRAINT [FK_encounter_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_encounters]'))
ALTER TABLE [dbo].[patient_encounters] CHECK CONSTRAINT [FK_encounter_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_staff]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_encounters]'))
ALTER TABLE [dbo].[patient_encounters]  WITH CHECK ADD  CONSTRAINT [FK_encounter_staff] FOREIGN KEY([staff_id])
REFERENCES [dbo].[staff] ([staff_id])
ON DELETE SET NULL
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_encounter_staff]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_encounters]'))
ALTER TABLE [dbo].[patient_encounters] CHECK CONSTRAINT [FK_encounter_staff]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_patient_encounters_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_encounters]'))
ALTER TABLE [dbo].[patient_encounters]  WITH CHECK ADD  CONSTRAINT [FK_patient_encounters_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_patient_encounters_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_encounters]'))
ALTER TABLE [dbo].[patient_encounters] CHECK CONSTRAINT [FK_patient_encounters_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_patient_encounters_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_encounters]'))
ALTER TABLE [dbo].[patient_encounters]  WITH CHECK ADD  CONSTRAINT [FK_patient_encounters_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_patient_encounters_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_encounters]'))
ALTER TABLE [dbo].[patient_encounters] CHECK CONSTRAINT [FK_patient_encounters_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_occupation_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_occupation]'))
ALTER TABLE [dbo].[patient_occupation]  WITH CHECK ADD  CONSTRAINT [FK_occupation_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_occupation_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_occupation]'))
ALTER TABLE [dbo].[patient_occupation] CHECK CONSTRAINT [FK_occupation_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_patient_occupation_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_occupation]'))
ALTER TABLE [dbo].[patient_occupation]  WITH CHECK ADD  CONSTRAINT [FK_patient_occupation_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_patient_occupation_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[patient_occupation]'))
ALTER TABLE [dbo].[patient_occupation] CHECK CONSTRAINT [FK_patient_occupation_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_patients_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[patients]'))
ALTER TABLE [dbo].[patients]  WITH CHECK ADD  CONSTRAINT [FK_patients_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_patients_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[patients]'))
ALTER TABLE [dbo].[patients] CHECK CONSTRAINT [FK_patients_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_payment_bill]') AND parent_object_id = OBJECT_ID(N'[dbo].[payments]'))
ALTER TABLE [dbo].[payments]  WITH CHECK ADD  CONSTRAINT [FK_payment_bill] FOREIGN KEY([bill_id])
REFERENCES [dbo].[bills] ([bill_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_payment_bill]') AND parent_object_id = OBJECT_ID(N'[dbo].[payments]'))
ALTER TABLE [dbo].[payments] CHECK CONSTRAINT [FK_payment_bill]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_payment_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[payments]'))
ALTER TABLE [dbo].[payments]  WITH CHECK ADD  CONSTRAINT [FK_payment_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_payment_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[payments]'))
ALTER TABLE [dbo].[payments] CHECK CONSTRAINT [FK_payment_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_payments_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[payments]'))
ALTER TABLE [dbo].[payments]  WITH CHECK ADD  CONSTRAINT [FK_payments_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_payments_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[payments]'))
ALTER TABLE [dbo].[payments] CHECK CONSTRAINT [FK_payments_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_payments_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[payments]'))
ALTER TABLE [dbo].[payments]  WITH CHECK ADD  CONSTRAINT [FK_payments_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_payments_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[payments]'))
ALTER TABLE [dbo].[payments] CHECK CONSTRAINT [FK_payments_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_perspiration_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration]  WITH CHECK ADD  CONSTRAINT [FK_perspiration_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_perspiration_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration] CHECK CONSTRAINT [FK_perspiration_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_perspiration_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration]  WITH CHECK ADD  CONSTRAINT [FK_perspiration_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_perspiration_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration] CHECK CONSTRAINT [FK_perspiration_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sweda_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration]  WITH CHECK ADD  CONSTRAINT [FK_sweda_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sweda_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration] CHECK CONSTRAINT [FK_sweda_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sweda_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration]  WITH CHECK ADD  CONSTRAINT [FK_sweda_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sweda_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[perspiration]'))
ALTER TABLE [dbo].[perspiration] CHECK CONSTRAINT [FK_sweda_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_phys_exam_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination]  WITH CHECK ADD  CONSTRAINT [FK_phys_exam_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_phys_exam_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination] CHECK CONSTRAINT [FK_phys_exam_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_phys_exam_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination]  WITH CHECK ADD  CONSTRAINT [FK_phys_exam_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_phys_exam_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination] CHECK CONSTRAINT [FK_phys_exam_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_physical_examination_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination]  WITH CHECK ADD  CONSTRAINT [FK_physical_examination_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_physical_examination_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination] CHECK CONSTRAINT [FK_physical_examination_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_physical_examination_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination]  WITH CHECK ADD  CONSTRAINT [FK_physical_examination_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_physical_examination_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[physical_examination]'))
ALTER TABLE [dbo].[physical_examination] CHECK CONSTRAINT [FK_physical_examination_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_poi_medicine]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_order_items]'))
ALTER TABLE [dbo].[purchase_order_items]  WITH CHECK ADD  CONSTRAINT [FK_poi_medicine] FOREIGN KEY([medicine_id])
REFERENCES [dbo].[medicines_master] ([medicine_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_poi_medicine]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_order_items]'))
ALTER TABLE [dbo].[purchase_order_items] CHECK CONSTRAINT [FK_poi_medicine]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_poi_po]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_order_items]'))
ALTER TABLE [dbo].[purchase_order_items]  WITH CHECK ADD  CONSTRAINT [FK_poi_po] FOREIGN KEY([po_id])
REFERENCES [dbo].[purchase_orders] ([po_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_poi_po]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_order_items]'))
ALTER TABLE [dbo].[purchase_order_items] CHECK CONSTRAINT [FK_poi_po]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_purchase_order_items_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_order_items]'))
ALTER TABLE [dbo].[purchase_order_items]  WITH CHECK ADD  CONSTRAINT [FK_purchase_order_items_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_purchase_order_items_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_order_items]'))
ALTER TABLE [dbo].[purchase_order_items] CHECK CONSTRAINT [FK_purchase_order_items_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_purchase_order_items_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_order_items]'))
ALTER TABLE [dbo].[purchase_order_items]  WITH CHECK ADD  CONSTRAINT [FK_purchase_order_items_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_purchase_order_items_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_order_items]'))
ALTER TABLE [dbo].[purchase_order_items] CHECK CONSTRAINT [FK_purchase_order_items_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_po_supplier]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_orders]'))
ALTER TABLE [dbo].[purchase_orders]  WITH CHECK ADD  CONSTRAINT [FK_po_supplier] FOREIGN KEY([supplier_id])
REFERENCES [dbo].[suppliers] ([supplier_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_po_supplier]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_orders]'))
ALTER TABLE [dbo].[purchase_orders] CHECK CONSTRAINT [FK_po_supplier]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_purchase_orders_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_orders]'))
ALTER TABLE [dbo].[purchase_orders]  WITH CHECK ADD  CONSTRAINT [FK_purchase_orders_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_purchase_orders_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_orders]'))
ALTER TABLE [dbo].[purchase_orders] CHECK CONSTRAINT [FK_purchase_orders_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_purchase_orders_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_orders]'))
ALTER TABLE [dbo].[purchase_orders]  WITH CHECK ADD  CONSTRAINT [FK_purchase_orders_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_purchase_orders_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[purchase_orders]'))
ALTER TABLE [dbo].[purchase_orders] CHECK CONSTRAINT [FK_purchase_orders_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refresh_tokens_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[refresh_tokens]'))
ALTER TABLE [dbo].[refresh_tokens]  WITH CHECK ADD  CONSTRAINT [FK_refresh_tokens_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refresh_tokens_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[refresh_tokens]'))
ALTER TABLE [dbo].[refresh_tokens] CHECK CONSTRAINT [FK_refresh_tokens_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refresh_tokens_user]') AND parent_object_id = OBJECT_ID(N'[dbo].[refresh_tokens]'))
ALTER TABLE [dbo].[refresh_tokens]  WITH CHECK ADD  CONSTRAINT [FK_refresh_tokens_user] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([user_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refresh_tokens_user]') AND parent_object_id = OBJECT_ID(N'[dbo].[refresh_tokens]'))
ALTER TABLE [dbo].[refresh_tokens] CHECK CONSTRAINT [FK_refresh_tokens_user]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refund_bill]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds]  WITH CHECK ADD  CONSTRAINT [FK_refund_bill] FOREIGN KEY([bill_id])
REFERENCES [dbo].[bills] ([bill_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refund_bill]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds] CHECK CONSTRAINT [FK_refund_bill]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refund_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds]  WITH CHECK ADD  CONSTRAINT [FK_refund_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refund_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds] CHECK CONSTRAINT [FK_refund_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refund_payment]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds]  WITH CHECK ADD  CONSTRAINT [FK_refund_payment] FOREIGN KEY([payment_id])
REFERENCES [dbo].[payments] ([payment_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refund_payment]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds] CHECK CONSTRAINT [FK_refund_payment]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refunds_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds]  WITH CHECK ADD  CONSTRAINT [FK_refunds_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refunds_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds] CHECK CONSTRAINT [FK_refunds_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refunds_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds]  WITH CHECK ADD  CONSTRAINT [FK_refunds_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_refunds_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[refunds]'))
ALTER TABLE [dbo].[refunds] CHECK CONSTRAINT [FK_refunds_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_reproductive_history_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[reproductive_history]'))
ALTER TABLE [dbo].[reproductive_history]  WITH CHECK ADD  CONSTRAINT [FK_reproductive_history_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_reproductive_history_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[reproductive_history]'))
ALTER TABLE [dbo].[reproductive_history] CHECK CONSTRAINT [FK_reproductive_history_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_reproductive_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[reproductive_history]'))
ALTER TABLE [dbo].[reproductive_history]  WITH CHECK ADD  CONSTRAINT [FK_reproductive_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_reproductive_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[reproductive_history]'))
ALTER TABLE [dbo].[reproductive_history] CHECK CONSTRAINT [FK_reproductive_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__role_acce__acces__1F83A428]') AND parent_object_id = OBJECT_ID(N'[dbo].[role_access_groups]'))
ALTER TABLE [dbo].[role_access_groups]  WITH CHECK ADD FOREIGN KEY([access_group_id])
REFERENCES [dbo].[access_groups] ([access_group_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__role_acce__role___1E8F7FEF]') AND parent_object_id = OBJECT_ID(N'[dbo].[role_access_groups]'))
ALTER TABLE [dbo].[role_access_groups]  WITH CHECK ADD FOREIGN KEY([role_id])
REFERENCES [dbo].[roles] ([role_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_role_access_groups_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[role_access_groups]'))
ALTER TABLE [dbo].[role_access_groups]  WITH CHECK ADD  CONSTRAINT [FK_role_access_groups_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_role_access_groups_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[role_access_groups]'))
ALTER TABLE [dbo].[role_access_groups] CHECK CONSTRAINT [FK_role_access_groups_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_roles_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[roles]'))
ALTER TABLE [dbo].[roles]  WITH CHECK ADD  CONSTRAINT [FK_roles_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_roles_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[roles]'))
ALTER TABLE [dbo].[roles] CHECK CONSTRAINT [FK_roles_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__screens__menu_id__4C8B54C9]') AND parent_object_id = OBJECT_ID(N'[dbo].[screens]'))
ALTER TABLE [dbo].[screens]  WITH CHECK ADD FOREIGN KEY([menu_id])
REFERENCES [dbo].[menus] ([menu_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__section_f__scree__5DB5E0CB]') AND parent_object_id = OBJECT_ID(N'[dbo].[section_fields]'))
ALTER TABLE [dbo].[section_fields]  WITH CHECK ADD FOREIGN KEY([screen_id])
REFERENCES [dbo].[screens] ([screen_id])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__section_f__secti__5EAA0504]') AND parent_object_id = OBJECT_ID(N'[dbo].[section_fields]'))
ALTER TABLE [dbo].[section_fields]  WITH CHECK ADD FOREIGN KEY([section_id])
REFERENCES [dbo].[sections] ([section_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__sections__screen__542C7691]') AND parent_object_id = OBJECT_ID(N'[dbo].[sections]'))
ALTER TABLE [dbo].[sections]  WITH CHECK ADD FOREIGN KEY([screen_id])
REFERENCES [dbo].[screens] ([screen_id])
ON DELETE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sensory_details_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[sensory_details]'))
ALTER TABLE [dbo].[sensory_details]  WITH CHECK ADD  CONSTRAINT [FK_sensory_details_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sensory_details_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[sensory_details]'))
ALTER TABLE [dbo].[sensory_details] CHECK CONSTRAINT [FK_sensory_details_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sensory_details_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[sensory_details]'))
ALTER TABLE [dbo].[sensory_details]  WITH CHECK ADD  CONSTRAINT [FK_sensory_details_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sensory_details_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[sensory_details]'))
ALTER TABLE [dbo].[sensory_details] CHECK CONSTRAINT [FK_sensory_details_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sensory_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[sensory_details]'))
ALTER TABLE [dbo].[sensory_details]  WITH CHECK ADD  CONSTRAINT [FK_sensory_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sensory_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[sensory_details]'))
ALTER TABLE [dbo].[sensory_details] CHECK CONSTRAINT [FK_sensory_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sensory_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[sensory_details]'))
ALTER TABLE [dbo].[sensory_details]  WITH CHECK ADD  CONSTRAINT [FK_sensory_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sensory_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[sensory_details]'))
ALTER TABLE [dbo].[sensory_details] CHECK CONSTRAINT [FK_sensory_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sleep_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD  CONSTRAINT [FK_sleep_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sleep_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns] CHECK CONSTRAINT [FK_sleep_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sleep_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD  CONSTRAINT [FK_sleep_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sleep_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns] CHECK CONSTRAINT [FK_sleep_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sleep_patterns_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD  CONSTRAINT [FK_sleep_patterns_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sleep_patterns_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns] CHECK CONSTRAINT [FK_sleep_patterns_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sleep_patterns_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns]  WITH CHECK ADD  CONSTRAINT [FK_sleep_patterns_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_sleep_patterns_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[sleep_patterns]'))
ALTER TABLE [dbo].[sleep_patterns] CHECK CONSTRAINT [FK_sleep_patterns_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_staff_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[staff]'))
ALTER TABLE [dbo].[staff]  WITH CHECK ADD  CONSTRAINT [FK_staff_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_staff_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[staff]'))
ALTER TABLE [dbo].[staff] CHECK CONSTRAINT [FK_staff_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_alert_inventory]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_alerts]'))
ALTER TABLE [dbo].[stock_alerts]  WITH CHECK ADD  CONSTRAINT [FK_alert_inventory] FOREIGN KEY([inventory_id])
REFERENCES [dbo].[inventory] ([inventory_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_alert_inventory]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_alerts]'))
ALTER TABLE [dbo].[stock_alerts] CHECK CONSTRAINT [FK_alert_inventory]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_alert_medicine]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_alerts]'))
ALTER TABLE [dbo].[stock_alerts]  WITH CHECK ADD  CONSTRAINT [FK_alert_medicine] FOREIGN KEY([medicine_id])
REFERENCES [dbo].[medicines_master] ([medicine_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_alert_medicine]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_alerts]'))
ALTER TABLE [dbo].[stock_alerts] CHECK CONSTRAINT [FK_alert_medicine]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_stock_alerts_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_alerts]'))
ALTER TABLE [dbo].[stock_alerts]  WITH CHECK ADD  CONSTRAINT [FK_stock_alerts_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_stock_alerts_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_alerts]'))
ALTER TABLE [dbo].[stock_alerts] CHECK CONSTRAINT [FK_stock_alerts_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_stock_alerts_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_alerts]'))
ALTER TABLE [dbo].[stock_alerts]  WITH CHECK ADD  CONSTRAINT [FK_stock_alerts_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_stock_alerts_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_alerts]'))
ALTER TABLE [dbo].[stock_alerts] CHECK CONSTRAINT [FK_stock_alerts_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_stock_transactions_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_transactions]'))
ALTER TABLE [dbo].[stock_transactions]  WITH CHECK ADD  CONSTRAINT [FK_stock_transactions_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_stock_transactions_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_transactions]'))
ALTER TABLE [dbo].[stock_transactions] CHECK CONSTRAINT [FK_stock_transactions_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_stock_transactions_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_transactions]'))
ALTER TABLE [dbo].[stock_transactions]  WITH CHECK ADD  CONSTRAINT [FK_stock_transactions_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_stock_transactions_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_transactions]'))
ALTER TABLE [dbo].[stock_transactions] CHECK CONSTRAINT [FK_stock_transactions_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_stxn_inventory]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_transactions]'))
ALTER TABLE [dbo].[stock_transactions]  WITH CHECK ADD  CONSTRAINT [FK_stxn_inventory] FOREIGN KEY([inventory_id])
REFERENCES [dbo].[inventory] ([inventory_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_stxn_inventory]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_transactions]'))
ALTER TABLE [dbo].[stock_transactions] CHECK CONSTRAINT [FK_stxn_inventory]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_stxn_medicine]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_transactions]'))
ALTER TABLE [dbo].[stock_transactions]  WITH CHECK ADD  CONSTRAINT [FK_stxn_medicine] FOREIGN KEY([medicine_id])
REFERENCES [dbo].[medicines_master] ([medicine_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_stxn_medicine]') AND parent_object_id = OBJECT_ID(N'[dbo].[stock_transactions]'))
ALTER TABLE [dbo].[stock_transactions] CHECK CONSTRAINT [FK_stxn_medicine]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_suppliers_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[suppliers]'))
ALTER TABLE [dbo].[suppliers]  WITH CHECK ADD  CONSTRAINT [FK_suppliers_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_suppliers_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[suppliers]'))
ALTER TABLE [dbo].[suppliers] CHECK CONSTRAINT [FK_suppliers_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tenant_subdomains_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[tenant_subdomains]'))
ALTER TABLE [dbo].[tenant_subdomains]  WITH CHECK ADD  CONSTRAINT [FK_tenant_subdomains_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tenant_subdomains_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[tenant_subdomains]'))
ALTER TABLE [dbo].[tenant_subdomains] CHECK CONSTRAINT [FK_tenant_subdomains_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tenants_plan]') AND parent_object_id = OBJECT_ID(N'[dbo].[tenants]'))
ALTER TABLE [dbo].[tenants]  WITH CHECK ADD  CONSTRAINT [FK_tenants_plan] FOREIGN KEY([plan_id])
REFERENCES [dbo].[subscription_plans] ([plan_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tenants_plan]') AND parent_object_id = OBJECT_ID(N'[dbo].[tenants]'))
ALTER TABLE [dbo].[tenants] CHECK CONSTRAINT [FK_tenants_plan]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_therapist_schedule_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_schedule]'))
ALTER TABLE [dbo].[therapist_schedule]  WITH CHECK ADD  CONSTRAINT [FK_therapist_schedule_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_therapist_schedule_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_schedule]'))
ALTER TABLE [dbo].[therapist_schedule] CHECK CONSTRAINT [FK_therapist_schedule_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_therapist_schedule_staff]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_schedule]'))
ALTER TABLE [dbo].[therapist_schedule]  WITH CHECK ADD  CONSTRAINT [FK_therapist_schedule_staff] FOREIGN KEY([therapist_id])
REFERENCES [dbo].[staff] ([staff_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_therapist_schedule_staff]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_schedule]'))
ALTER TABLE [dbo].[therapist_schedule] CHECK CONSTRAINT [FK_therapist_schedule_staff]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_therapist_schedule_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_schedule]'))
ALTER TABLE [dbo].[therapist_schedule]  WITH CHECK ADD  CONSTRAINT [FK_therapist_schedule_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_therapist_schedule_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_schedule]'))
ALTER TABLE [dbo].[therapist_schedule] CHECK CONSTRAINT [FK_therapist_schedule_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_therapist_slots_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_slots]'))
ALTER TABLE [dbo].[therapist_slots]  WITH CHECK ADD  CONSTRAINT [FK_therapist_slots_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_therapist_slots_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_slots]'))
ALTER TABLE [dbo].[therapist_slots] CHECK CONSTRAINT [FK_therapist_slots_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_therapist_slots_staff]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_slots]'))
ALTER TABLE [dbo].[therapist_slots]  WITH CHECK ADD  CONSTRAINT [FK_therapist_slots_staff] FOREIGN KEY([therapist_id])
REFERENCES [dbo].[staff] ([staff_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_therapist_slots_staff]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_slots]'))
ALTER TABLE [dbo].[therapist_slots] CHECK CONSTRAINT [FK_therapist_slots_staff]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_therapist_slots_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_slots]'))
ALTER TABLE [dbo].[therapist_slots]  WITH CHECK ADD  CONSTRAINT [FK_therapist_slots_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_therapist_slots_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[therapist_slots]'))
ALTER TABLE [dbo].[therapist_slots] CHECK CONSTRAINT [FK_therapist_slots_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_urinary_habits_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits]  WITH CHECK ADD  CONSTRAINT [FK_urinary_habits_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_urinary_habits_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits] CHECK CONSTRAINT [FK_urinary_habits_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_urinary_habits_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits]  WITH CHECK ADD  CONSTRAINT [FK_urinary_habits_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_urinary_habits_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits] CHECK CONSTRAINT [FK_urinary_habits_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_urine_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits]  WITH CHECK ADD  CONSTRAINT [FK_urine_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_urine_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits] CHECK CONSTRAINT [FK_urine_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_urine_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits]  WITH CHECK ADD  CONSTRAINT [FK_urine_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_urine_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[urinary_habits]'))
ALTER TABLE [dbo].[urinary_habits] CHECK CONSTRAINT [FK_urine_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_branches_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_branches]'))
ALTER TABLE [dbo].[user_branches]  WITH CHECK ADD  CONSTRAINT [FK_user_branches_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_branches_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_branches]'))
ALTER TABLE [dbo].[user_branches] CHECK CONSTRAINT [FK_user_branches_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_branches_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_branches]'))
ALTER TABLE [dbo].[user_branches]  WITH CHECK ADD  CONSTRAINT [FK_user_branches_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_branches_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_branches]'))
ALTER TABLE [dbo].[user_branches] CHECK CONSTRAINT [FK_user_branches_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_branches_user]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_branches]'))
ALTER TABLE [dbo].[user_branches]  WITH CHECK ADD  CONSTRAINT [FK_user_branches_user] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([user_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_branches_user]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_branches]'))
ALTER TABLE [dbo].[user_branches] CHECK CONSTRAINT [FK_user_branches_user]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_roles_role]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_roles]'))
ALTER TABLE [dbo].[user_roles]  WITH CHECK ADD  CONSTRAINT [FK_user_roles_role] FOREIGN KEY([role_id])
REFERENCES [dbo].[roles] ([role_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_roles_role]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_roles]'))
ALTER TABLE [dbo].[user_roles] CHECK CONSTRAINT [FK_user_roles_role]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_roles_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_roles]'))
ALTER TABLE [dbo].[user_roles]  WITH CHECK ADD  CONSTRAINT [FK_user_roles_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_roles_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_roles]'))
ALTER TABLE [dbo].[user_roles] CHECK CONSTRAINT [FK_user_roles_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_roles_user]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_roles]'))
ALTER TABLE [dbo].[user_roles]  WITH CHECK ADD  CONSTRAINT [FK_user_roles_user] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([user_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_roles_user]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_roles]'))
ALTER TABLE [dbo].[user_roles] CHECK CONSTRAINT [FK_user_roles_user]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_users_staff]') AND parent_object_id = OBJECT_ID(N'[dbo].[users]'))
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FK_users_staff] FOREIGN KEY([staff_id])
REFERENCES [dbo].[staff] ([staff_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_users_staff]') AND parent_object_id = OBJECT_ID(N'[dbo].[users]'))
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FK_users_staff]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_users_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[users]'))
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FK_users_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_users_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[users]'))
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FK_users_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_complaints_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_complaints]'))
ALTER TABLE [dbo].[visit_complaints]  WITH CHECK ADD  CONSTRAINT [FK_complaints_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_complaints_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_complaints]'))
ALTER TABLE [dbo].[visit_complaints] CHECK CONSTRAINT [FK_complaints_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_complaints_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_complaints]'))
ALTER TABLE [dbo].[visit_complaints]  WITH CHECK ADD  CONSTRAINT [FK_complaints_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_complaints_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_complaints]'))
ALTER TABLE [dbo].[visit_complaints] CHECK CONSTRAINT [FK_complaints_patient]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_visit_complaints_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_complaints]'))
ALTER TABLE [dbo].[visit_complaints]  WITH CHECK ADD  CONSTRAINT [FK_visit_complaints_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_visit_complaints_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_complaints]'))
ALTER TABLE [dbo].[visit_complaints] CHECK CONSTRAINT [FK_visit_complaints_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_visit_complaints_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_complaints]'))
ALTER TABLE [dbo].[visit_complaints]  WITH CHECK ADD  CONSTRAINT [FK_visit_complaints_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_visit_complaints_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_complaints]'))
ALTER TABLE [dbo].[visit_complaints] CHECK CONSTRAINT [FK_visit_complaints_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_visit_vitals_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_vitals]'))
ALTER TABLE [dbo].[visit_vitals]  WITH CHECK ADD  CONSTRAINT [FK_visit_vitals_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branches] ([branch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_visit_vitals_branch]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_vitals]'))
ALTER TABLE [dbo].[visit_vitals] CHECK CONSTRAINT [FK_visit_vitals_branch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_visit_vitals_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_vitals]'))
ALTER TABLE [dbo].[visit_vitals]  WITH CHECK ADD  CONSTRAINT [FK_visit_vitals_tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[tenants] ([tenant_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_visit_vitals_tenant]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_vitals]'))
ALTER TABLE [dbo].[visit_vitals] CHECK CONSTRAINT [FK_visit_vitals_tenant]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_vitals_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_vitals]'))
ALTER TABLE [dbo].[visit_vitals]  WITH CHECK ADD  CONSTRAINT [FK_vitals_encounter] FOREIGN KEY([encounter_id])
REFERENCES [dbo].[patient_encounters] ([encounter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_vitals_encounter]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_vitals]'))
ALTER TABLE [dbo].[visit_vitals] CHECK CONSTRAINT [FK_vitals_encounter]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_vitals_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_vitals]'))
ALTER TABLE [dbo].[visit_vitals]  WITH CHECK ADD  CONSTRAINT [FK_vitals_patient] FOREIGN KEY([patient_id])
REFERENCES [dbo].[patients] ([patient_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_vitals_patient]') AND parent_object_id = OBJECT_ID(N'[dbo].[visit_vitals]'))
ALTER TABLE [dbo].[visit_vitals] CHECK CONSTRAINT [FK_vitals_patient]
GO
