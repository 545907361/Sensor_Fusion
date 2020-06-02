signal_cfar = [];

for i = 1:100 
    signal =i;
    if(signal<55)
        signal=0;
    end
     signal_cfar = [signal_cfar, {signal}];
end
