local M={}
M.rows={
 {cr="0",hp1=1,hp2=6,ac=13,d1=0,d2=1,atk=3,dc=13},{cr="1/8",hp1=7,hp2=35,ac=13,d1=2,d2=3,atk=3,dc=13},{cr="1/4",hp1=36,hp2=49,ac=13,d1=4,d2=5,atk=3,dc=13},{cr="1/2",hp1=50,hp2=70,ac=13,d1=6,d2=8,atk=3,dc=13},
 {cr="1",hp1=71,hp2=85,ac=13,d1=9,d2=14,atk=3,dc=13},{cr="2",hp1=86,hp2=100,ac=13,d1=15,d2=20,atk=3,dc=13},{cr="3",hp1=101,hp2=115,ac=13,d1=21,d2=26,atk=4,dc=13},{cr="4",hp1=116,hp2=130,ac=14,d1=27,d2=32,atk=5,dc=14},{cr="5",hp1=131,hp2=145,ac=15,d1=33,d2=38,atk=6,dc=15},{cr="6",hp1=146,hp2=160,ac=15,d1=39,d2=44,atk=6,dc=15},{cr="7",hp1=161,hp2=175,ac=15,d1=45,d2=50,atk=6,dc=15},{cr="8",hp1=176,hp2=190,ac=16,d1=51,d2=56,atk=7,dc=16},{cr="9",hp1=191,hp2=205,ac=16,d1=57,d2=62,atk=7,dc=16},{cr="10",hp1=206,hp2=220,ac=17,d1=63,d2=68,atk=7,dc=16},
 {cr="11",hp1=221,hp2=235,ac=17,d1=69,d2=74,atk=8,dc=17},{cr="12",hp1=236,hp2=250,ac=17,d1=75,d2=80,atk=8,dc=17},{cr="13",hp1=251,hp2=265,ac=18,d1=81,d2=86,atk=8,dc=18},{cr="14",hp1=266,hp2=280,ac=18,d1=87,d2=92,atk=8,dc=18},{cr="15",hp1=281,hp2=295,ac=18,d1=93,d2=98,atk=8,dc=18},{cr="16",hp1=296,hp2=310,ac=18,d1=99,d2=104,atk=9,dc=18},{cr="17",hp1=311,hp2=325,ac=19,d1=105,d2=110,atk=10,dc=19},{cr="18",hp1=326,hp2=340,ac=19,d1=111,d2=116,atk=10,dc=19},{cr="19",hp1=341,hp2=355,ac=19,d1=117,d2=122,atk=10,dc=19},{cr="20",hp1=356,hp2=400,ac=19,d1=123,d2=140,atk=10,dc=19},
 {cr="21",hp1=401,hp2=445,ac=19,d1=141,d2=158,atk=11,dc=20},{cr="22",hp1=446,hp2=490,ac=19,d1=159,d2=176,atk=11,dc=20},{cr="23",hp1=491,hp2=535,ac=19,d1=177,d2=194,atk=11,dc=20},{cr="24",hp1=536,hp2=580,ac=19,d1=195,d2=212,atk=12,dc=21},{cr="25",hp1=581,hp2=625,ac=19,d1=213,d2=230,atk=12,dc=21},{cr="26",hp1=626,hp2=670,ac=19,d1=231,d2=248,atk=12,dc=21},{cr="27",hp1=671,hp2=715,ac=19,d1=249,d2=266,atk=13,dc=22},{cr="28",hp1=716,hp2=760,ac=19,d1=267,d2=284,atk=13,dc=22},{cr="29",hp1=761,hp2=805,ac=19,d1=285,d2=302,atk=13,dc=22},{cr="30",hp1=806,hp2=850,ac=19,d1=303,d2=320,atk=14,dc=23}}
local function near(i,delta) local n=i+delta; if n<1 then n=1 elseif n>#M.rows then n=#M.rows end; return n end
local function find(hp,key1,key2) for i,r in ipairs(M.rows) do if hp>=r[key1] and hp<=r[key2] then return i end end; return hp<1 and 1 or #M.rows end
function M.calculate(hp,ac,dpr,attack,dc,useSave)
 local di=find(hp,"hp1","hp2"); di=near(di,math.floor(((ac-M.rows[di].ac)/2)+0.5))
 local oi=find(dpr,"d1","d2"); local expected=useSave and M.rows[oi].dc or M.rows[oi].atk; local actual=useSave and dc or attack; oi=near(oi,math.floor(((actual-expected)/2)+0.5))
 local avg=(di+oi)/2; local fi=math.floor(avg+0.5); if fi<1 then fi=1 elseif fi>#M.rows then fi=#M.rows end
 return M.rows[fi].cr,M.rows[di].cr,M.rows[oi].cr,M.rows[di],M.rows[oi]
end
return M
