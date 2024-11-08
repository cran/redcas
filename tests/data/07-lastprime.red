%% $Id: 07-lastprime.red,v 1.2 2024/09/04 11:19:17 mg Exp $

%% Purpose: long-running reduce code for testing notification and abort

%% $Log: 07-lastprime.red,v $
%% Revision 1.2  2024/09/04 11:19:17  mg
%% Added runs of lastprime for 10^26, 10^27, 10^28
%%

%% find largest prime smaller than a given natural number

on echo ;

procedure lastprime (n) ;
   begin scalar k, kfact ;
      k:=n+1 ;
      repeat
      << k:=k-1 ;
	 kfact:=factorize(k)
      >> until length(kfact) = 1 and second(first(kfact))=1;
      return first(first(kfact))
   end ;

showtime ; %% to reset the counter
for k:=24:28 do <<
    kp:=10^k;
    kpf:=lastprime(kp);
    write "10E", k, " ", kpf;
    showtime >>;




