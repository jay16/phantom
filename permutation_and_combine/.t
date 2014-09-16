    declare @tableName nvarchar(max)
    set @tableName = 'project';

    -- 递归遍历出@tableName外键链

    with
       cte_fk (fk_name, referenced, parent, fk_level)
     as (
       select
        name as fk_name,
        object_name(referenced_object_id) as referenced,
        object_name(parent_object_id) as parent,
        1 as fk_level
       from sys.foreign_keys
       where object_name(referenced_object_id) = @tableName

       union all

       select
        fk.name as fk_name,
        object_name(fk.referenced_object_id) as referenced,
        object_name(fk.parent_object_id) as parent,
        cf.fk_level + 1 as fk_level
       from sys.foreign_keys fk
       inner join cte_fk cf on cf.parent = object_name(fk.referenced_object_id)
     )
     select * from cte_fk order by cte_fk.fk_level
