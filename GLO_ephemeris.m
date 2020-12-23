classdef GLO_ephemeris < handle
   properties
        raw_data;
        protocol = char(zeros(4,32));
   end
    
   methods
       function model = GLO_ephemeris(ephemeris_raw_data)
           model.raw_data = fliplr(ephemeris_raw_data);
           for j = 1:4
              for i = 1:4
                  model.protocol(j,(8*(i)-7):8*(i)) = dec2bin(hex2dec(model.raw_data(j,i)),8);
              end
           end
       end
       
       function [num,string] = frame(model)
            num = bin2dec(model.protocol(4,25:32));
            string = bin2dec(model.protocol(1,2:5));
       end
       
       function [P1,tk,vx,ax,x] = string1(model)
            P1 = bin2dec(model.protocol(1,8:9));
            tk = bin2dec(model.protocol(1,10:21)); % 시간으로 바꿀 것
            vx = bin2dec(append(model.protocol(1,22:32),model.protocol(2,1:13)))*2^-20;
            ax = bin2dec(model.protocol(2,14:18))*2^-30;
            x  = bin2dec(append(model.protocol(2,19:32),model.protocol(3,1:13)))*2^-11;           
       end
       
       function [Bn,P2,tb,vy,ay,y] = string2(model)
            Bn = bin2dec(model.protocol(1,6:8));
            P2 = bin2dec(model.protocol(1,9));
            tb = bin2dec(model.protocol(1,10:16))*15;
            vy = bin2dec(append(model.protocol(1,22:32),model.protocol(2,1:13)))*2^-20;
            ay = bin2dec(model.protocol(2,14:18))*2^-30;
            y  = bin2dec(append(model.protocol(2,19:32),model.protocol(3,1:13)))*2^-11;        
       end
       
       function [P3,rn,P,ln,vz,az,z] = string3(model)
            P3 = bin2dec(model.protocol(1,6));
            rn = bin2dec(model.protocol(1,7:17))*2^-40;
            P  = bin2dec(model.protocol(1,20));
            ln = bin2dec(model.protocol(1,21));
            vz = bin2dec(append(model.protocol(1,22:32),model.protocol(2,1:13)))*2^-20;
            az = bin2dec(model.protocol(2,14:18))*2^-30;
            z  = bin2dec(append(model.protocol(2,19:32),model.protocol(3,1:13)))*2^-11;           
       end
       
       function [taun,del_taun,En,P4,FT,NT,n,M] = string4(model)
            taun = bin2dec(model.protocol(1,6:27));
            del_taun = bin2dec(model.protocol(1,28:32));
            En = bin2dec(model.protocol(2,1:5));
            P4 = bin2dec(model.protocol(2,20));
            FT = bin2dec(model.protocol(2,21:24));
            NT = bin2dec(append(model.protocol(2,28:32),model.protocol(3,1:6)));
            n  = bin2dec(model.protocol(3,7:11));
            M = bin2dec(model.protocol(3,12:13));
       end
       
       function [NA,tau_c,N4,tau_GPS,ln] = string5(model)
            NA = bin2dec(model.protocol(1,6:16));
            tau_c = bin2dec(append(model.protocol(1,17:32),model.protocol(2,1:16)))*2^-27;
            N4 = bin2dec(model.protocol(2,18:22));
            tau_GPS = bin2dec(append(model.protocol(2,23:32),model.protocol(3,1:12)))*2^-30;
            ln = bin2dec(model.protocol(3,13));
       end
       
       function [Cn,Man,nA,tau_An,lamda_An,del_i_An,e_An] = string_even(model)
            Cn = bin2dec(model.protocol(1,6));
            Man = bin2dec(model.protocol(1,7:8));
            nA  = bin2dec(model.protocol(1,9:13));
            tau_An = bin2dec(model.protocol(1,14:23))*2^-18;
            lamda_An = bin2dec(append(model.protocol(1,24:32),model.protocol(2,1:12)))*2^-20;
            del_i_An = bin2dec(model.protocol(2,13:30))*2^-18;
            e_An = bin2dec(append(model.protocol(2,31:32),model.protocol(3,1:13)))*2^-20; 
       end
       
       function [w_An,tau_Alam,del_T_An,del_dotT_An,del_H_An,ln] = string_odd(model)
            w_An = bin2dec(model.protocol(1,6:21))*2^-15;
            tau_Alam = bin2dec(append(model.protocol(1,22:32),model.protocol(2,1:10))); % 보류
            del_T_An = bin2dec(model.protocol(2,11:32))*2^-9;
            del_dotT_An = bin2dec(model.protocol(3,1:7))*2^-14;
            del_H_An = bin2dec(model.protocol(3,8:12));
            ln = bin2dec(model.protocol(3,13));           
       end
       
       function [B1,B2,KP] = string14_5(model)
            B1 = bin2dec(model.protocol(1,11))*2^-10;
            B2 = bin2dec(model.protocol(1,11:20))*2^-16;
            KP = bin2dec(model.protocol(1,21:22));
       end
   end
end