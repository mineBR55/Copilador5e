local M={}
M.budget={
 [1]={50,75,100},[2]={100,150,200},[3]={150,225,400},[4]={250,375,500},[5]={500,750,1100},
 [6]={600,1000,1400},[7]={750,1300,1700},[8]={1000,1700,2100},[9]={1300,2000,2600},[10]={1600,2300,3100},
 [11]={1900,2900,4100},[12]={2200,3700,4700},[13]={2600,4200,5400},[14]={2900,4900,6200},[15]={3300,5400,7800},
 [16]={3800,6100,9800},[17]={4500,7200,11700},[18]={5000,8700,14200},[19]={5500,10700,17200},[20]={6400,13200,22000}}
M.crXP={['0']=10,['1/8']=25,['1/4']=50,['1/2']=100,['1']=200,['2']=450,['3']=700,['4']=1100,['5']=1800,['6']=2300,['7']=2900,['8']=3900,['9']=5000,['10']=5900,['11']=7200,['12']=8400,['13']=10000,['14']=11500,['15']=13000,['16']=15000,['17']=18000,['18']=20000,['19']=22000,['20']=25000,['21']=33000,['22']=41000,['23']=50000,['24']=62000,['25']=75000,['26']=90000,['27']=105000,['28']=120000,['29']=135000,['30']=155000}
function M.partyBudget(groups)
 local out={0,0,0}; local count=0
 for _,g in ipairs(groups or {}) do local level=math.max(1,math.min(20,tonumber(g.level) or 1)); local qty=math.max(0,tonumber(g.qty) or 0); count=count+qty; for i=1,3 do out[i]=out[i]+M.budget[level][i]*qty end end
 return out,count
end
function M.totalXP(monsters) local x=0; for _,m in ipairs(monsters or {}) do x=x+(tonumber(m.xp) or 0)*math.max(0,tonumber(m.qty) or 0) end; return x end
function M.rate(x,b) if x<=0 then return 'Sem criaturas' elseif x<=b[1] then return 'Baixo' elseif x<=b[2] then return 'Moderado' elseif x<=b[3] then return 'Alto' else return 'Acima do Alto' end end
function M.evaluate(groups,monsters) local b,c=M.partyBudget(groups); local x=M.totalXP(monsters); return {budget=b,characters=c,xp=x,difficulty=M.rate(x,b),remainingHigh=b[3]-x} end
return M
