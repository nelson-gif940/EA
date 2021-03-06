//___ ____ ____ ___  ____    _  _ ____ _    ___  ____ ____ 
// |  |__/ |__| |  \ |___    |__| |___ |    |__] |___ |__/ 
// |  |  \ |  | |__/ |___    |  | |___ |___ |    |___ |  \

// __              ___ __     
//)_) \_)    )\ ) )_  )_) (/ 
///__)  /    (  ( (__ / \  /)


// ------------------------------------------------------- //
// LOG : ///////////
// 15.11 _ Prog close all, break even for all (so put on the first trad). Also added a close all for the challenge if equity is above fixed final_eq.
// 16.11 _ Get rid of the lots indicator, seems to influence trading in a bad way.
// 17.11 _ Added a function that move the stoploss at the right place and a function that automatically create a stop loss for the second order
// 18.11 _ Adding a function that buy an order or sell with correct stop directly
// 19.12 _ Adding screen shot for open - close
// 20.12 _ Normalise Double et closed screen shot
// 18.01 _ Changed the BE to Open OrderPrice... (3BE become one loss)
// 20.01 _ Put back BE to -2*Spread & Cleanded the code
// 26.01 _ Added Last lots information to reenter trade
// 13.03 _ Clearned the code to upload on github
// -------------------------------------------------------- //

//.  ..__..__ ._..__..__ .   .___ __.
//\  /[__][__) | [__][__)|   [__ (__ 
// \/ |  ||  \_|_|  |[__)|___[___.__)
//-----------------------------------

//Empty variable initialization

float stop;
float tp;
float stop_initialization;
float first_stop;
float open_buy_stop;
double open_buy_lots;
double open_sell_lots;
float open_sell_stop;
float tp1;

//Paramaters

extern double risk=1.5;
extern double acc_balance=100000;
extern float risk_flat=1.9;
float last_lots=0;
double pips=1;

//Challenge Version & Final Equity stop

extern bool challenge_version=True;
extern float final_eq=110100;

//.___.  ..  . __ .___.._..__..  . __.
//[__ |  ||\ |/  `  |   | |  ||\ |(__ 
//|   |__|| \|\__.  |  _|_|__|| \|.__)
//------------------------------------

//+------------------------------------------------------------------+
//CLOSE ALL TRADES 
//+------------------------------------------------------------------+

int CloseAll()
  {
   for(int i=0; i<OrdersTotal()+1; i++)
     {
      OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
      OrderClose(OrderTicket(),OrderLots(),Ask,3,Blue);
     };
   return(0);
  };

//+------------------------------------------------------------------+
//PUT ALL TRADE TO BREAK EVEN
//+------------------------------------------------------------------+

int BreakEven()
  {
   for(int i=0; i<OrdersTotal()+1; i++)
     {
      OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_BUY){
      OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-0*(Ask-Bid),OrderTakeProfit(),OrderExpiration(),Blue);};
      if(OrderType()==OP_SELL){
      OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+0*(Ask-Bid),OrderTakeProfit(),OrderExpiration(),Blue);};
     };
  };
  
//+------------------------------------------------------------------+
//SET STOP (FOR THE FIRST TRADE)
//+------------------------------------------------------------------+

int SetStop()
   {
   OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
   if(Close[1]<Open[1]){
         stop_initialization=High[1]+2*MathAbs(Ask-Bid);};
   if(Close[1]>Open[1]){
          stop_initialization=Low[1]-2*MathAbs(Ask-Bid);};
   OrderModify(OrderTicket(),OrderOpenPrice(),stop_initialization,OrderTakeProfit(),OrderExpiration(),Green);
   };
   
//+------------------------------------------------------------------+
//SET STOP (TO THE SAME AS THE FIRST TRADE)
//+------------------------------------------------------------------+

int SetSecondStop()
   {
   OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
   first_stop=OrderStopLoss();
   for(int k=1;k<OrdersTotal()+1;k++){
   OrderSelect(k,SELECT_BY_POS,MODE_TRADES);
   OrderModify(OrderTicket(),OrderOpenPrice(),stop,OrderTakeProfit(),OrderExpiration(),Green);
   };};
   
//+------------------------------------------------------------------+
//OPEN ORDER BUY
//+------------------------------------------------------------------+

int OpenOrderBuy()
   {
   if(Symbol()!="XAUUSD"){
   open_buy_stop=Low[1]-2*MathAbs(Ask-Bid);
   open_buy_lots=NormalizeDouble(risk_flat/(Ask-open_buy_stop)/100,2);
   OrderSend(Symbol(),OP_BUY,open_buy_lots,Ask,3,NormalizeDouble(open_buy_stop,5),"OrderBuy",10000,0,Blue);
   };
   if(Symbol()=="XAUUSD"){
   open_buy_stop=Low[1]-2*MathAbs(Ask-Bid);
   open_buy_lots=NormalizeDouble(risk_flat/(Ask-open_buy_stop)*10,2);
   OrderSend(Symbol(),OP_BUY,open_buy_lots,Ask,3,NormalizeDouble(open_buy_stop,5),"OrderBuy",10000,0,Blue);
   };
   last_lots=open_buy_lots;
   tp1=NormalizeDouble(OrderOpenPrice()+(OrderOpenPrice()-Low[1])*2.5,5);   
   };

//+------------------------------------------------------------------+
//OPEN ORDER SELL
//+------------------------------------------------------------------+

int OpenOrderSell()
   {
   if(Symbol()!="XAUUSD"){
   open_sell_stop=High[1]+2*MathAbs(Ask-Bid);
   open_sell_lots=NormalizeDouble(risk_flat/(open_sell_stop-Ask)/100,2);
   OrderSend(Symbol(),OP_SELL,open_sell_lots,Ask,3,NormalizeDouble(open_sell_stop,5),"OrderSell",0,0,Blue);
   Print(NormalizeDouble(open_sell_stop,5));
   Print(open_sell_lots);
   };
   if(Symbol()=="XAUUSD"){
   open_sell_stop=High[1]+2*MathAbs(Ask-Bid);
   open_sell_lots=NormalizeDouble(risk_flat/(open_sell_stop-Ask)*10,2);
   OrderSend(Symbol(),OP_SELL,open_sell_lots,Ask,3,NormalizeDouble(open_sell_stop,5),"OrderSell",10000,0,Blue);
   };
   last_lots=open_sell_lots;
   tp1=NormalizeDouble(OrderOpenPrice()-(open_sell_stop-High[1])*2.5,5);
   };
   

//+------------------------------------------------------------------+
//KEY PRESSED -> RESULT
//+------------------------------------------------------------------+

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
     {
     
      string bars="0";
      
      if(id==CHARTEVENT_KEYDOWN)
        {
         switch(int (lparam))
           {
            case 70:
              {
               CloseAll();
               ChartScreenShot(0,bars+"_close.gif",1280,800,ALIGN_RIGHT);
               break;
              }
            case 87:
              {
               BreakEven();
               break;
              }
            case 89:
              {
              SetStop();
              break;
              };
            case 86:
              {
              SetSecondStop();
              break;
              };
            case 90:
              {
              OpenOrderBuy();
              ChartScreenShot(0,IntegerToString(Bars)+"_open.gif",1280,800,ALIGN_RIGHT);
              bars=IntegerToString(Bars);
              Print("Order Buy sent");
              break;
              };
            case 78:
              {
              OpenOrderSell();
              ChartScreenShot(0,IntegerToString(Bars)+"_open.gif",1280,800,ALIGN_RIGHT);
              bars=IntegerToString(Bars);
              Print("Order Sell sent");
              break;
              };
            case 76:
              {
              ChartScreenShot(0,IntegerToString(Bars)+"_close.gif",1280,800,ALIGN_RIGHT);
              break;
              };
             case 80:
              {
              ObjectsDeleteAll();
              break;
              };
              
            default:
              Print("Don't recognize the key");
           }
        };
     };
     

// __..___..__..__ .___.
//(__   |  [__][__)  |  
//.__)  |  |  ||  \  |
//---------------------

void OnTick()
  {

   //------------------------------
   //NEW ORDER -> STOP LOSS AND TP AUTOMATICALLY PUT ON THE FIRST ORDER
   //------------------------------
   
   if(OrdersTotal()>1)
     {

      OrderSelect(0,SELECT_BY_POS,MODE_TRADES);

      stop = OrderStopLoss();

      tp = OrderTakeProfit();

      Print(stop, tp);
      
      int cnt=0;

      for(int i=1; i<OrdersTotal(); i++)
        {

         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

         OrderModify(OrderTicket(),OrderOpenPrice(),stop,tp,OrderExpiration(),Blue);
         
         cnt=cnt+1;
         

        };

     };
         
     if(OrdersTotal()==0){
     
       cnt=0;
       
       };
       
   //------------------------------
   //NEW ORDER -> STOP LOSS AND TP AUTOMATICALLY PUT ON THE FIRST ORDER
   //------------------------------
       
     double risk_bal=(risk/100)*acc_balance;
     
     if(Ask<Open[0]){pips=High[0]-Ask+0.00003;}
     if(Ask>Open[0]){pips=Ask-Low[0]+0.00003;}

   //------------------------------
   //SCREEN DISPLAY
   //------------------------------
                
     Comment("\n \n \n \n \n \n"+"Challenge \n"+"Order Total :  "+OrdersTotal() + " \nRisk (dollars) :  " + NormalizeDouble(risk_flat,2)+ "\nRisk (percentages) :  " + NormalizeDouble(risk_flat/AccountEquity()*1000,3) + "\nSeconds :  " + Seconds() + "\nSpread :" + MathRound((Ask-Bid)*100000)+"\nLast lots : " + last_lots + "\nTp1 = " + tp1);

   //------------------------------
   //CHALLENGE VERSION
   //------------------------------
     
     if(challenge_version==True){
        if(AccountEquity()>final_eq&&OrdersTotal()>0){
            for(int n=0; n<OrdersTotal()+1; n++)
                 {
                  OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
                  OrderClose(OrderTicket(),OrderLots(),Ask,2,Green);
                 };
            return(0);
          };
          };  
};

