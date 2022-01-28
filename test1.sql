


-------------1.2 4种-省月聚合--------------------
select
    t3.index_month,
    t3.amount1/t3.amounts as w1,
    t3.amount2/t3.amounts as w2,
    t3.amount3/t3.amounts as w3,
    t3.amount4/t3.amounts as w4,
    t3.amount1/t3.quantity1 as p1,
    t3.amount2/t3.quantity2 as p2,
    t3.amount3/t3.quantity3 as p3,
    t3.amount4/t3.quantity4 as p4,
    t3.amounts as m,       --当月总支出
    t3.quantities as q
from
(
select
    t2.index_month,
    max(case when t2.shipin_type=1 then t2.amount else null end) as amount1,
    max(case when t2.shipin_type=2 then t2.amount else null end) as amount2,
    max(case when t2.shipin_type=3 then t2.amount else null end) as amount3,
    max(case when t2.shipin_type=4 then t2.amount else null end) as amount4,
    max(case when t2.shipin_type=1 then t2.quantity else null end) as quantity1,
    max(case when t2.shipin_type=2 then t2.quantity else null end) as quantity2,
    max(case when t2.shipin_type=3 then t2.quantity else null end) as quantity3,
    max(case when t2.shipin_type=4 then t2.quantity else null end) as quantity4,
    max(t2.all_amount) as amounts,
    max(t2.all_quantity) as quantities
from
(
SELECT 
    t1.province_name,
    t1.index_month,
    t1.shipin_type,
    t1.all_amount,
    t1.all_quantity,
    sum(t1.sum_amount) as amount,
    sum(t1.sum_quantity) as quantity
    --sum(t1.sum_amount) over(partition by t1.province_name,t1.index_month,t1.shipin_type) as amount,
    --sum(t1.sum_quantity) over(partition by t1.province_name,t1.index_month,t1.shipin_type) as quantity,
    --sum(t1.sum_amount) over(partition by t1.province_name,t1.index_month) as all_amount,
    --sum(t1.sum_quantity) over(partition by t1.province_name,t1.index_month) as all_quantity,

FROM 
(
    SELECT province_name,
        index_month,
        sum_amount,
        sum_quantity,
        sum(sum_amount) over(partition by province_name,index_month) as all_amount,
        sum(sum_quantity) over(partition by province_name,index_month) as all_quantity,
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
        ) as shipin_type
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
) as t1
GROUP by
    t1.province_name,
    t1.index_month,
    t1.shipin_type,
    t1.all_amount,
    t1.all_quantity

) as t2
where t2.province_name='安徽省'
group by t2.index_month
) as t3

;
