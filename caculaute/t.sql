declare @sql nvarchar(max) @_originalId nvarchar(max);
set @_originalId = convert(varchar, @originalId);
set @sql = '';

declare c1 for select [sql] from [dbo].[sGetReferencedInfo](@tableName, @_originalId) order by [fk_level] desc;
declare @tSql nvarchar(max);

open c1
fetch c1 into @tSql;
while(@@fetch_status = 0)
begin
  set @sql = @sql + char(10) + @tSql;

  fetch c1 into @tSql;
end
close c1
deallocate c1

select @sql
