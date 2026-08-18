/*
    Stock moving between a clinic's own branches.

    Stock is physical, so it belongs to the branch whose shelf it sits on. That is
    right, and it creates a need the single-branch product never had: one branch runs
    short of something another has plenty of, and the answer should be to move it
    rather than to order more.

    A transfer is two movements, not one adjustment. The sending branch loses the
    stock and the receiving branch gains it, and both sides are recorded — so a
    shortfall at one end and a surplus at the other can always be traced to the same
    event rather than looking like two unexplained corrections.

    The existing check constraints allowed neither, so they are widened here.
    Adjustment would have fitted the shape and told the reader nothing about why the
    quantity moved.

    Run AFTER 12-number-series.sql. Idempotent.
*/
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

DECLARE @txnCheck SYSNAME = (
    SELECT TOP 1 cc.name FROM sys.check_constraints cc
    WHERE cc.parent_object_id = OBJECT_ID('dbo.stock_transactions')
      AND cc.definition LIKE '%Dispensed%');

IF @txnCheck IS NOT NULL
BEGIN
    DECLARE @drop NVARCHAR(400) = N'ALTER TABLE dbo.stock_transactions DROP CONSTRAINT ' + QUOTENAME(@txnCheck);
    EXEC sp_executesql @drop;
    PRINT '  dropped ' + @txnCheck;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_stock_transactions_txn_type')
    ALTER TABLE dbo.stock_transactions ADD CONSTRAINT CK_stock_transactions_txn_type
        CHECK (txn_type IN (N'Opening_stock', N'Purchase', N'Dispensed', N'Adjustment',
                            N'Expired', N'Return_to_supplier', N'Return_from_patient',
                            -- the two halves of a move between branches
                            N'Transfer_out', N'Transfer_in'));
GO

DECLARE @refCheck SYSNAME = (
    SELECT TOP 1 cc.name FROM sys.check_constraints cc
    WHERE cc.parent_object_id = OBJECT_ID('dbo.stock_transactions')
      AND cc.definition LIKE '%Expiry_removal%');

IF @refCheck IS NOT NULL
BEGIN
    DECLARE @drop2 NVARCHAR(400) = N'ALTER TABLE dbo.stock_transactions DROP CONSTRAINT ' + QUOTENAME(@refCheck);
    EXEC sp_executesql @drop2;
    PRINT '  dropped ' + @refCheck;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_stock_transactions_reference_type')
    ALTER TABLE dbo.stock_transactions ADD CONSTRAINT CK_stock_transactions_reference_type
        CHECK (reference_type IS NULL
            OR reference_type IN (N'Purchase_order', N'Bill', N'Manual', N'Expiry_removal',
                                  N'Branch_transfer'));
GO

------------------------------------------------------------------ report
SELECT '  txn types allowed       : ' +
       CASE WHEN EXISTS (SELECT 1 FROM sys.check_constraints
                         WHERE name = 'CK_stock_transactions_txn_type'
                           AND definition LIKE '%Transfer_in%')
            THEN 'now includes Transfer_out and Transfer_in' ELSE 'MISSING' END;

SELECT '  reference types allowed : ' +
       CASE WHEN EXISTS (SELECT 1 FROM sys.check_constraints
                         WHERE name = 'CK_stock_transactions_reference_type'
                           AND definition LIKE '%Branch_transfer%')
            THEN 'now includes Branch_transfer' ELSE 'MISSING' END;
