

-------------1.2 4种-省月聚合--------------------
select
    index_month,
    amount1/amounts as w1,
    amount2/amounts as w2,
    amount3/amounts as w3,
    amount4/amounts as w4,
    amount1/quantity1 as p1,
    amount2/quantity2 as p2,
    amount3/quantity3 as p3,
    amount4/quantity4 as p4,
    amounts as m,       --当月总支出
    quantities as q
from
(
select
    index_month,
    max(case when shipin_type=1 then amount else null end) as amount1,
    max(case when shipin_type=2 then amount else null end) as amount2,
    max(case when shipin_type=3 then amount else null end) as amount3,
    max(case when shipin_type=4 then amount else null end) as amount4,
    max(case when shipin_type=1 then quantity else null end) as quantity1,
    max(case when shipin_type=2 then quantity else null end) as quantity2,
    max(case when shipin_type=3 then quantity else null end) as quantity3,
    max(case when shipin_type=4 then quantity else null end) as quantity4,
    max(all_amount) as amounts,
    max(all_quantity) as quantities
from
(
SELECT 
    province_name,
    index_month,
    --cls_2,
    --cls_3,
    --cls_4,
    (case when
        (cls_4 in ('米','面粉','挂面','波纹面','杂粮','杂粮粉')
        or cls_3='食用油' ) then 1
    when
        cls_4 in ('豆制品','根茎类蔬菜','菌菇类蔬菜','茄果瓜菜','叶菜类蔬菜','泡菜/酸菜','包装水果') then 2
    when
        (cls_4 in ('冷冻猪肉','冷冻鸡肉','冷冻鸭肉','鱼类水产','虾类水产','蟹类水产')
        or cls_3='蛋品'
        or cls_2='奶制品' ) then 3
    when
        cls_3='坚果炒货' then 4
    end
    ) as shipin_type,
    sum(sum_amount) as amount,
    sum(sum_quantity) as quantity,
    sum(sum_amount) over(partition by province_name,index_month) as all_amount,
    sum(sum_quantity) over(partition by province_name,index_month) as all_quantity
FROM zhidou_hz_dev.shipin_province_monthly_info
WHERE 
    province_name in ('河南省','安徽省','重庆省','广东省','江苏省','山东省')
    AND 
    (
        cls_4 in ('米','面粉','挂面','波纹面','杂粮','杂粮粉',
                    '豆制品','根茎类蔬菜','菌菇类蔬菜','茄果瓜菜','叶菜类蔬菜',
                    '泡菜/酸菜','包装水果','冷冻猪肉','冷冻鸡肉','冷冻鸭肉',
                    '鱼类水产','虾类水产','蟹类水产')
        OR 
        cls_3 in ('坚果炒货','蛋品','食用油')
        OR 
        cls_2 in ('奶制品')
    )
GROUP BY 
    province_name,
    index_month,
    --cls_2,
    --cls_3,
    --cls_4,
    (case when
        (cls_4 in ('米','面粉','挂面','波纹面','杂粮','杂粮粉')
        or cls_3='食用油' ) then 1
    when
        cls_4 in ('豆制品','根茎类蔬菜','菌菇类蔬菜','茄果瓜菜','叶菜类蔬菜','泡菜/酸菜','包装水果') then 2
    when
        (cls_4 in ('冷冻猪肉','冷冻鸡肉','冷冻鸭肉','鱼类水产','虾类水产','蟹类水产')
        or cls_3='蛋品'
        or cls_2='奶制品' ) then 3
    when
        cls_3='坚果炒货' then 4
    end
    )
order by
    province_name,
    index_month,
    shipin_type

) as t1
where t1.province_name='安徽省'
group by index_month
) as t2

;
