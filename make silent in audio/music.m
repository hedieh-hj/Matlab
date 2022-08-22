[y,fs]=audioread('music3.m4a');
subplot(2,1,1);
plot(y);
y(4*fs:6*fs,:)=0;
subplot(2,1,2);
plot(y);