program TypicalGame;
uses crt;
const
	filename = 'auth.txt';
type
	THSide = (right, left);

	GameAmmo = record	
		HomeX, HomeY: integer;	
		CurX, CurY: integer;
		Symb: char;
	end;

	GameMap = record
		HomeX, HomeY: integer;
		CurX, CurY: integer;
	end;

	GameEnemy = record
		CurX, CurY: integer;
		ASymb: char;
		DSymb: char;
		Ammo: GameAmmo;
		Alive: boolean;
	end;

	GameTH = record { Typical hero }
		HomeX, HomeY: integer;
		CurX, CurY: integer;
		MaxLX, MaxRX: integer; { Border for moving TH }
		ASymb: char;
		DSymb: char;
		Ammo: GameAmmo;
		Side: THSide;
		Alive: boolean;
	end;

	GameEnemyArray = array [0..9] of GameEnemy;

var		{ Global Variables }
	auth: text;
	EAS: integer; { Enemy Attack Speed }
	THAS: integer; { Typical Hero Attack Speed } 
	DeadEnemy: integer;

procedure zeroing_all(var map: GameMap; var enemyar: GameEnemyArray; var th: GameTH);
var
	i, k: integer;
begin
	EAS := 150;
	THAS := 50;
	DeadEnemy := 0;

	map.HomeX := (ScreenWidth - 22) div 2; { Zeroing map}
	map.HomeY := (ScreenHeight - 6) div 2;
	map.CurX := map.HomeX;
	map.CurY := map.HomeY;
	
	k := 2;					{ Zeroing Array of Enemy }
	for i := 0 to 9 do
	begin
		enemyar[i].CurX := map.HomeX + k;
		enemyar[i].CurY := map.HomeY + 1;
		enemyar[i].ASymb := #79; { O }
		enemyar[i].DSymb := #88; { X }
		enemyar[i].Ammo.Symb := #46; { . }
		enemyar[i].Ammo.HomeX := enemyar[i].CurX;
		enemyar[i].Ammo.HomeY := enemyar[i].CurY + 1;
		enemyar[i].Ammo.CurX := enemyar[i].Ammo.HomeX;
		enemyar[i].Ammo.CurY := enemyar[i].Ammo.HomeY;
		enemyar[i].Alive := true;
		k := k + 2;
	end;

	th.HomeX := map.HomeX + 11;		{ Zeroing Typical Hero }
	th.HomeY := map.HomeY + 5;
	th.CurX := th.HomeX;
	th.CurY := th.HomeY;
	th.MaxLX := th.HomeX - 11;
	th.MaxRX := th.HomeX + 11;
	th.ASymb := #94; { ^ }
	th.DSymb := #126;{ ~ }
	th.Ammo.Symb := #34; { " }
	th.Ammo.CurX := th.HomeX;
	th.Ammo.CurY := th.HomeY - 1;
	th.Alive := true;
end;

procedure DrawMap(var map: GameMap); { Map 22x6 }
var
       	i, j: integer;
begin
	clrscr;
	GotoXY(map.HomeX, map.HomeY);

	for i := 1 to 7 do { Drawing Map }
	begin
		write('|');
		for j := 1 to 21 do
			write(' ');
		write('|');

		if i = 1 then { Drawing Up }
		begin
			GotoXY(map.CurX, map.CurY);
			write(' ');
			for j := 1 to 21 do
				write('_');
			write(' ');
		end;
		
		if i = 7 then { Drawing Bottom }
		begin
			GotoXY(map.CurX, map.CurY);
			write('|');
			for j := 1 to 21 do
				write('_');
			write('|');
		end;
		map.CurY := map.CurY + 1;
		GotoXY(map.CurX, map.CurY);
	end;

end;

procedure RegAccount(map: GameMap);
var
	x, y, n: integer;
	uname: string;
	ch: char;
begin
	DrawMap(map);
	x := Map.HomeX + 5;
	y := Map.HomeY + 2;
	GotoXY(x, y);
	write('Create account');
	y := y + 2;
	GotoXY(x, y);
	write('Username: ');
	n := 1;

	while true do
	begin
		ch := ReadKey;
		if ch = #13 then
			break;
		uname[n] := ch;
		if n <= 6 then
			write(uname[n]);
		n := n + 1;
	end;

	rewrite(auth);
	for n := 1 to 6 do
		write(auth, uname[n]);
	close(auth);
	clrscr;
end;

procedure StartMessage(map: GameMap);
var
       	x, y: integer;
	uname: string;
	ch: char;
begin
	{$I-}
	assign(auth, filename);
	reset(auth);
	if IOresult <> 0 then
	begin
		RegAccount(map);
		reset(auth);
	end;
	DrawMap(map);
	x := map.HomeX + 7;
	y := map.HomeY + 2;
	GotoXY(x, y);
	read(auth, uname);
	write('Hi ', uname);

	x := x - 2;
	y := y + 2;
	GotoXY(x, y);
	write('Want to play?');
	x := x + 4;
	y := y + 1;
	GotoXY(x, y);
	write('[Y/n]');
	repeat
		ch := ReadKey;
	until ch in [#89, #121, #78, #110];
	if ch in [#78, #110] then
	begin
		clrscr;
		x := (ScreenWidth - 6) div 2;
		y := ScreenHeight div 2;
		GotoXY(x, y);
		write('Bye...');
		delay(2000);
		halt;
	end;
	close(auth);
	clrscr;
end;
	{ Procedures for Typical Hero } 
procedure ShowTH(th: GameTH);
begin
	GotoXY(th.CurX, th.CurY);
	write(th.ASymb);
end;

procedure HideTH(th: GameTH);
begin
	GotoXY(th.CurX, th.CurY);
	write(' ');
end;

procedure MoveTH(var th: GameTH);
begin
	HideTH(th);
	if th.Side = left then
		begin
			if th.CurX - 1 = th.MaxLX then
			begin
				ShowTH(th);
				exit;
			end;

			th.CurX := th.CurX - 1;
			ShowTH(th);
		end;

	if th.Side = right then
	begin
		if th.CurX + 1 = th.MaxRX then
		begin
			ShowTH(th);
			exit;
		end;

		th.CurX := th.CurX + 1;
		ShowTH(th);
	end;
end;

procedure HandleArrowKey(var th: GameTH; ch: char);
begin
	case ch of
	#97: th.Side := left;
	#100: th.Side := right;
	end;
	
	MoveTH(th);
end;

procedure MovementControl(var th: GameTH);
var
	ch: char;
begin
	ch := ReadKey;
	if ch in [#97, #100] then
		HandleArrowKey(th, ch);
	if ch = #27 then
	begin
		clrscr;
		halt(0);
	end;

end;

procedure ShowTHAmmo(th: GameTH);
begin
	GotoXY(th.Ammo.CurX, th.Ammo.CurY);
	write(th.Ammo.Symb);
end;

procedure HideTHAmmo(th: GameTH);
begin
	GotoXY(th.Ammo.CurX, th.Ammo.CurY);
	write(' ');	
end;

procedure ShootTH(var th: GameTH; var enemyar: GameEnemyArray);
var
	i, j, n, distance: integer;
begin
	n := 0;
	th.Ammo.CurX := th.CurX;
	th.Ammo.CurY := th.CurY - 1;
	distance := th.CurY - enemyar[1].CurY;
	GotoXY(th.Ammo.CurX, th.Ammo.CurY);

	for i := 1 to distance do
	begin
		ShowTHAmmo(th);
		delay(THAS);
		MovementControl(th);
		HideTHAmmo(th);
		th.Ammo.CurY := th.Ammo.CurY - 1;

		if th.Ammo.CurY = enemyar[1].CurY then
		begin
			for j := 0 to 9 do
			begin
				if enemyar[j].CurX = th.Ammo.CurX then
					n := j;
			end;
			if n > 0 then
			begin
				enemyar[n].Alive := false;
				DeadEnemy := DeadEnemy + 1;
				th.Ammo.CurX := th.CurX;
				th.Ammo.CurY := th.CurY - 1;
				exit;
			end;
		end;

	end;
end;

procedure CheckAliveTH(th: GameTH);
var
       	x,y: integer;
begin
	if not th.Alive then
	begin
		GotoXY(th.CurX, th.CurY);
		write(th.DSymb);
		x := (ScreenWidth - 8) div 2;
		y := ScreenHeight div 2;
		GotoXY(x, y);
		write('You lose');
		delay(3000);
		clrscr;
		halt(0);
	end;
end;
	{ Procedures for enemy }
procedure ShowEnemy(enemyar: GameEnemyArray);
var
       	i: integer;
begin
	for i := 0 to 9 do
	begin
		GotoXY(enemyar[i].CurX, enemyar[i].CurY);
		write(enemyar[i].ASymb);
	end;
end;

procedure ShowEnemyAmmo(enemyar: GameEnemyArray; n: integer);
begin
	GotoXY(enemyar[n].Ammo.CurX, enemyar[n].Ammo.CurY);
	write(enemyar[n].Ammo.Symb);
end;

procedure HideEnemyAmmo(enemyar: GameEnemyArray; n: integer);
begin
	GotoXY(enemyar[n].Ammo.CurX, enemyar[n].Ammo.CurY);
	write(' ');
end;

procedure ShootEnemy(var enemyar: GameEnemyArray; var th: GameTH);
var
       	i, randint, distance: integer;
begin
	repeat
		randint := random(10);
	until enemyar[randint].Alive;

	enemyar[randint].Ammo.CurX := enemyar[randint].Ammo.HomeX;
	enemyar[randint].Ammo.CurY := enemyar[randint].Ammo.HomeY;
	distance := th.HomeY - enemyar[randint].CurY; { 4 }
	GotoXY(enemyar[randint].Ammo.CurX, enemyar[randint].Ammo.CurY);

	for i := 1 to distance do
	begin
		ShowEnemyAmmo(enemyar, randint);
		Delay(EAS);
		MovementControl(th);
		HideEnemyAmmo(enemyar, randint);
		enemyar[randint].Ammo.CurY := enemyar[randint].Ammo.CurY + 1;
		if enemyar[randint].Ammo.CurY = th.CurY then
		begin
			if enemyar[randint].Ammo.CurX = th.CurX then
			begin
				th.Alive := FALSE;
				enemyar[randint].Ammo.CurX := enemyar[randint].Ammo.HomeY;
				enemyar[randint].Ammo.CurY := enemyar[randint].Ammo.HomeY;
				exit;
			end;
		end;	
		GotoXY(enemyar[randint].Ammo.CurX, enemyar[randint].Ammo.CurY);
	end;
end;

procedure CheckAliveEnemy(enemyar: GameEnemyArray);
var
       	i, x, y: integer;
begin
	for i := 0 to 9 do
	begin
		if not enemyar[i].Alive then
		begin
			GotoXY(enemyar[i].CurX, enemyar[i].CurY);
			write(enemyar[i].DSymb);
		end;
		EAS := 150 - (DeadEnemy * 15);
	end;
	if DeadEnemy = 10 then
	begin
		x := (ScreenWidth - 7) div 2;
		y := ScreenHeight div 2;
		GotoXY(x, y);
		write('You win');
	end;
end;
	{ Main }
var
	map: GameMap;
	enemyar: GameEnemyArray;
	th: GameTH;
begin
	clrscr;
	randomize;
	zeroing_all(map, enemyar, th);
	StartMessage(map);
	DrawMap(map);
	ShowEnemy(enemyar);
	ShowTH(th);
	delay(2000);
	while true do
		begin
			if not KeyPressed then
			begin
				ShootEnemy(enemyar, th);
				CheckAliveTH(th);
				ShootTH(th, enemyar);
				CheckAliveEnemy(enemyar);
				continue;
			end;
			MovementControl(th);
		end;
end.
