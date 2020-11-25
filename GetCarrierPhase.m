function pseudo_range = GetPseudoRange(pseudo_range_raw)

    pseudo_range_raw2 = fliplr(pseudo_range_raw);
    pseudo_range_bin = strings(size(pseudo_range_raw,1),1);
    pseudo_range = zeros(size(pseudo_range_raw2,1),1);
    for i = 1:size(pseudo_range_raw,1)
        for j = 1:size(pseudo_range_raw,2)
            pseudo_range_raw2(i,j) = dec2bin((hex2dec((pseudo_range_raw2(i,j)))),8);
            pseudo_range_bin(i,1) = pseudo_range_bin(i,1) + pseudo_range_raw2(i,j);
        end
    end
    for k = 1: size(pseudo_range_bin,1)
        S = extractBefore(pseudo_range_bin(k,1),2);
        E = extractBetween(pseudo_range_bin(k,1),2,12);
        F = extractAfter(pseudo_range_bin(k,1),12);
        pseudo_range(k,1) = (-1)^ bin2dec(S) * (1 + bin2dec(F)/(2^52)) * 2^(bin2dec(E)-1023);
    end

end

