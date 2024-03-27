%Pasul 1
s=tf('s');
P=10/(s*(100*s+1)*(0.1*s+1));
poli_P=pole(P) %Sistemul nu este stabil BIBO in sens strict, intrucat are un pol egal cu 0. 
%Este insa stabil BIBO in sens nestrict.
%Modelul nominal are polul p=0 care limiteaza inferior zona pe care se
%poate asigura stabilitate robusta, din cauza celor doua constrangeri de
%interpolare care apar in acest pol: S(p)=0, T(p)=1.

%Pasul 2
%Principiul modelului intern: pentru a urmari o referinta de tip treapta
%unitara cu eroare stationara nula, polii transformatei Laplace ai referinței
%trebuie să se găsească printre polii procesului sau ai compensatorului, din 
%cauza polului instabil.
W_S=1000/(10*s+1); %W_S este stabil si respecta contitia ca |S(jw)|<=0.01, adica |Ws(jw)|>=1000
%W_S a fost ales ca un filtru trece-jos de ordinul 1 cu amplificarea 1/eroare si pulsatia de 
%taiere omega banda
figure(1);
bodemag(W_S, P);
% In banda de trecere unde |P(jw)|>>1, trebuie sa asiguram |L(jw)|>>1, fapt
% posibil intrucat lărgimea de bandă |W_S(jw)|>>1 nu o depăsește pe cea a procesului nominal.

%Pasul 3
figure(2);
W_T=(0.01*s)/(0.001*s+1);
bodemag(W_S, W_T);
%Se incalca resrictia ca min{|WS(jω)|,|WT(jω)|} < 1. Alegem un W_S care
%coboara mai repede (adaugam poli).
W_S=1000/(100*s+1)^3;
figure(3);
bodemag(W_S, W_T);
grid on
%Acum, conditia de buna definire este indeplinita.
%Din grafic, omega2 = 110 rad/s si omega1 = 0.1 rad/s, iar diferenta dintre
%ele este suficient de mare pentru ca proiectarea functiei de transfer in
%bucla deschisa sa nu fie dificila (aproximativ 3 decade)

%Pasul 4
omega_jf=logspace(-4, -1, 1e3);
omega_if=logspace(2, 5, 1e3);

figure(4);
Ws_jf=bode(W_S, omega_jf);
Wt_jf=bode(W_T, omega_jf);
Ws_jf=squeeze(Ws_jf);
Wt_jf=squeeze(Wt_jf);
R_jf=Ws_jf./(1.-Wt_jf);
plot(log10(omega_jf), mag2db(R_jf));
hold on;

Ws_if=bode(W_S, omega_if);
Wt_if=bode(W_T, omega_if);
Ws_if=squeeze(Ws_if);
Wt_if=squeeze(Wt_if);
R_if=(1.-Ws_if)./mag_Wt_if;
plot(log10(omega_if), mag2db(R_if));
hold on;

omega_jf=logspace(-4, -1, 1e3);
omega_mf=logspace(-1, 2, 1e3);
omega_if=logspace(2, 5, 1e3);

Ws_jf=bode(W_S, omega_jf);
Wt_jf=bode(W_T, omega_jf);
Ws_jf=squeeze(Ws_jf);
Wt_jf=squeeze(Wt_jf);
R_jf=Ws_jf./(1.-Wt_jf);
plot(log10(omega_jf), mag2db(R_jf));
hold on;

Ws_if=bode(W_S, omega_if);
Wt_if=bode(W_T, omega_if);
Ws_if=squeeze(Ws_if);
Wt_if=squeeze(Wt_if);
R_if=(1.-Ws_if)./Wt_if;
plot(log10(omega_if), mag2db(R_if));
hold on;

L=100/(s*(s+1)*(s/10+1)*(s/100+1));
L_jf=bode(L, omega_jf);
L_mf=bode(L, omega_mf);
L_if=bode(L, omega_if);
L_jf=squeeze(L_jf);
L_mf=squeeze(L_mf);
L_if=squeeze(L_if);
plot(log10(omega_jf), mag2db(L_jf));
plot(log10(omega_mf), mag2db(L_mf));
plot(log10(omega_if), mag2db(L_if));
grid on

C_1=L/P;
C_1=tf(ss(C_1,'min'));
zero_C=zero(C_1)
poli_C=pole(C_1)

%Pasul 5
figure(5);
bode(L);
%Marginea de fază este de -40 grade. Regulatorul trebuie inseriat
%cu un bloc de avans de fază. Pulsatia de taiere a lui L este aproximativ 9.
C_faza=18/4.5*(s+4.5)/(s+18);
C_2=C_1*C_faza;
L=C_2*P;
figure;
bode(L);