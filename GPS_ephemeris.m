classdef GPS_ephemeris < handle
    properties
        raw_data;
        protocol= char(zeros(10,32));
    end
    
    methods
        function model = GPS_ephemeris(ephemeris_raw_data)
            model.raw_data = fliplr(ephemeris_raw_data);
            for j = 1:10
                for i = 1:4
                    model.protocol(j,(8*(i)-7):8*(i)) = dec2bin(hex2dec(model.raw_data(j,i)),8);
                end
            end
        end
        
        function num = FrameNumber(model)
            num = bin2dec(model.protocol(2,20:22));
        end
        
        function sig = CheckPad(model)
            sig = bin2dec(model.protocol(1,1:2)); 
        end
        
        function [WN,toc,af1,af2,af3] = subframe1(model)
            WN = bin2dec(model.protocol(3,3:12))+1024;
            toc = bin2dec(model.protocol(8,11:26))*2^4; 

            af1 = model.protocol(9,3:10);
            if af1(1,1)==1
                af1 = -(2^8-bin2dec(model.protocol(9,3:10)))*2^(-55);
            else
                af1 = bin2dec(model.protocol(9,3:10))*2^(-55);
            end

            af2 = model.protocol(9,11:26);
            if af2(1,1)==1
                af2 = -(2^16-bin2dec(model.protocol(9,11:26)))*2^(-43);
            else
                af2 = bin2dec(model.protocol(9,11:26))*2^(-43);
            end     

            af3 = model.protocol(10,3:24);
            if af3(1,1)==1
                af3 = -(2^22-bin2dec(model.protocol(10,3:24)))*2^(-31);
            else
                af3 = bin2dec(model.protocol(10,3:24))*2^(-31);
            end                    
        end
        
        function [Crs,del_n,M0,Cuc,e,Cus,root_A,toe] = subframe2(model)
            Crs = model.protocol(3,11:26);
            if Crs(1,1)==1
                Crs = -(2^16-bin2dec(model.protocol(3,11:26)))*2^(-5);
            else
                Crs = bin2dec(model.protocol(3,11:26))*2^(-5);
            end   

            del_n = model.protocol(4,3:18);
            if del_n(1,1)==1
                del_n = -(2^16-bin2dec(model.protocol(4,3:18)))*2^(-43);
            else
                del_n = bin2dec(model.protocol(4,3:18))*2^(-43);
            end  

            M0 = append(model.protocol(4,19:26),model.protocol(5,3:26));
            if M0(1,1)==1
                M0 = -(2^32-bin2dec(M0))*2^(-31);
            else
                M0 = bin2dec(M0)*2^(-31);
            end   

            Cuc = model.protocol(6,3:18);
            if Cuc(1,1)==1
                Cuc = -(2^16-bin2dec(Cuc))*2^(-29);
            else
                Cuc = bin2dec(Cuc)*2^(-29);
            end  

            e = bin2dec(append(model.protocol(6,19:26),model.protocol(7,3:26)))*2^(-33);

            Cus = model.protocol(8,3:18);
            if Cuc(1,1)==1
                Cus = -(2^16-bin2dec(Cus))*2^(-29);
            else
                Cus = bin2dec(Cus)*2^(-29);
            end  

            root_A = bin2dec(append(model.protocol(8,19:26),model.protocol(9,3:26)))*2^(-19);
            toe = bin2dec(model.protocol(10,3:18))*2^4;            
        end
        
        function [Cic,omega0,Cis,i0,Crc,w,dot_omega,dot_i] = subframe3(model)
            Cic = model.protocol(3,3:18);
            if Cic(1,1)==1
                Cic = -(2^16-bin2dec(Cic))*2^(-29);
            else
                Cic = bin2dec(Cic)*2^(-29);
            end  

            omega0 = append(model.protocol(3,19:26),model.protocol(4,3:26));        
            if omega0(1,1)==1
                omega0 = -(2^32-bin2dec(omega0))*2^(-31);
            else
                omega0 = bin2dec(omega0)*2^(-31);
            end

            Cis = model.protocol(5,3:18);
            if Cis(1,1)==1
                Cis = -(2^16-bin2dec(Cis))*2^(-29);
            else
                Cis = bin2dec(Cis)*2^(-29);
            end

            i0 = append(model.protocol(5,19:26),model.protocol(6,3:26));
            if i0(1,1)==1
                i0 = -(2^32-bin2dec(i0))*2^(-31);
            else
                i0 = bin2dec(i0)*2^(-31);
            end

            Crc = model.protocol(7,3:18);
            if Crc(1,1)==1
                Crc = -(2^16-bin2dec(Crc))*2^(-5);
            else
                Crc = bin2dec(Crc)*2^(-5);
            end

            w = append(model.protocol(7,19:26),model.protocol(8,3:26));
            if w(1,1)==1
                w = -(2^32-bin2dec(w))*2^(-31);
            else
                w = bin2dec(w)*2^(-31);
            end

            dot_omega = model.protocol(9,3:26);
            if dot_omega(1,1)==1
                dot_omega = -(2^24-bin2dec(dot_omega))*2^(-43);
            else
                dot_omega = bin2dec(dot_omega)*2^(-43);
            end

            dot_i = model.protocol(10,11:24);
            if dot_i(1,1)==1
                dot_i = -(2^14-bin2dec(dot_i))*2^(-43);
            else
                dot_i = bin2dec(dot_i)*2^(-43);
            end            
        end
    end 
end