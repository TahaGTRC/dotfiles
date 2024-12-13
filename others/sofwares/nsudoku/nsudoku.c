/*
nsudoku 1.3

Copyright (c) 2008-2015 Tin Benjamin Matuka

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use, 
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

To compile nsudoku run
$ gcc -o nsudoku nsudoku.c -lncurses

I have no intention of updating this game, because I made it
just to learn how to work with ncurses. You can use the code
if you want to.

For more information visit nsudoku web site:
http://www.tbmatuka.com/nsudoku

I can be contacted at mail[at]tbmatuka[dot]com

*/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ncurses.h>
#include <string.h>

#define CTRL(c) ((c) & 037)
#define VERSION "1.3"

int board[9][9], start[9][9];
WINDOW *helpbox, *win;

int check(void); // check if all numbers in board array match the rules
int clear_grid(int i, int j); // clear a grid(3x3) in row i and column j
int count(void); // count how many values are in board array
int generate(int n); // generate sudoku
int stdprint(void); // stdout print board array
int change(int x, int y, int num); // change a value of an array field.
int helpboxon(void); // turn HelpBox on
int helpboxoff(void); // turn HelpBox off
int restart(void);
void printhelp(void);
void printversion(void);

int main(int argc, char *argv[])
	{
	int n = 0, color = 1, print = 1;
	int len, i;
	
	srand(time(NULL));
	
	while (argc > 1)
		{
		if (argv[1][0] == '-' && argv[1][1] == '-')
			{
			if (strcmp(&argv[1][2], "version") == 0)
				{
				printversion();
				return 0;
				}
			else if (strcmp(&argv[1][2], "no-color") == 0)
				{
				color = 0;
				}
			else if (strcmp(&argv[1][2], "no-print") == 0)
				{
				print = 0;
				}
			else if (strcmp(&argv[1][2], "help") == 0)
				{
				printhelp();
				return 0;
				}
			else
				{
				printf("Bad argument: %s\n", argv[1]);
				return 1;
				}
			}
		else if (argv[1][0] == '-')
			{
			len = strlen(argv[1]);
			for(i = 1; i < len; i++)
				{
				if (argv[1][i] == 'v')
					{
					printversion();
					return 0;
					}
				else if (argv[1][i] == 'h')
					{
					printhelp();
					return 0;
					}
				else if (argv[1][i] == 'c')
					{
					color = 0;
					}
				else if (argv[1][i] == 'p')
					{
					print = 0;
					}
				else
					{
					printf("Bad switch: %c\n", argv[1][i]);
					return 1;
					}
				}
			}
		else n = atoi(argv[1]);

		++argv;
		--argc;
		}
	
	if(n < 1 || n > 80) n = 40;
	int ch, j, hb = 1;
	int maxx, __attribute__((unused)) maxy, startx, starty;
	int posx = 0, posy = 0;
	generate(n);
	initscr();
	getmaxyx(stdscr, maxy, maxx);
	startx = (maxx - 38) / 2;
	if(hb == 1 && startx < 16) startx = 16;
	if(hb == 1 && maxx < 54) startx = maxx - 38;
	starty = 2;
	noecho();
	if(color == 1) start_color();
	init_pair(1, COLOR_CYAN, COLOR_BLACK);
	init_pair(2, COLOR_BLUE, COLOR_BLACK);
	keypad(stdscr, TRUE);
	win = newwin(25, 37, starty, startx);
	helpbox = newwin(12, 15, 1, 1);
	wbkgd(win, COLOR_PAIR(1));
	werase(win);
	refresh();
	wrefresh(win);
	for(i = 0;i < 10;i++)
		{
		for(j = 0;j < 10;j++)
			{
			if(i % 3 == 0) wattron(win, A_BOLD|COLOR_PAIR(2));
			if(j % 3 == 0) wattron(win, A_BOLD|COLOR_PAIR(2));
			wprintw(win, "+");
			if(j % 3 == 0 && i % 3 != 0)
				{
				wattron(win, COLOR_PAIR(1));
				wattroff(win, A_BOLD);
				}
			if(j < 9) wprintw(win, "---");
			if(i % 3 == 0)
				{
				wattron(win, COLOR_PAIR(1));
				wattroff(win, A_BOLD);
				}
			}
		for(j = 0;j < 10 && i < 9;j++)
			{
			if(j % 3 == 0) wattron(win, A_BOLD|COLOR_PAIR(2));
			if(j > 0) wprintw(win, "   |");
			else wprintw(win, "|");
			if(j % 3 == 0)
				{
				wattron(win, COLOR_PAIR(1));
				wattroff(win, A_BOLD);
				}
			}
		}
	for(i = 0;i < 9;i++)
		for(j = 0;j < 9;j++)
			if(board[i][j] != 0)
				{
				wattron(win, A_BOLD);
				mvwprintw(win, i*2+1, j*4+2, "%d", board[i][j]);
				wattroff(win, A_BOLD);
				}
	helpboxon();
	wmove(win, 1, 2);
	wrefresh(win);
	while(ch != 'q' && ch != 900)
		{
		ch = getch();
		if(ch == 'r') restart();
		else if((ch == KEY_RIGHT || ch == 'l') && posx < 8) posx++;
		else if((ch == KEY_LEFT || ch == 'h') && posx > 0) posx--;
		else if((ch == KEY_DOWN || ch == 'j') && posy < 8) posy++;
		else if((ch == KEY_UP || ch == 'k') && posy > 0) posy--;
		else if(ch == 330 || ch == KEY_BACKSPACE)
			{
			if(start[posy][posx] == 0)
				{
				board[posy][posx] = 0;
				wprintw(win, " ");
				}
			}
		else if(ch-48 > 0 && ch-48 < 10)
			{
			if(start[posy][posx] == 0)
				{
				board[posy][posx] = ch-48;
				wprintw(win, "%d", ch-48);
				}
			}
		else if(ch == CTRL('L') || ch == CTRL('R') || ch == KEY_RESIZE || ch == 'H')
			{
			if(ch == 'H')
				{
				if(hb == 1)
					{
					helpboxoff();
					hb = 0;
					}
				else
					{
					helpboxon();
					hb = 1;
					}
				}
			endwin();
			initscr();
			erase();
			getmaxyx(stdscr, maxy, maxx);
			startx = (maxx - 38) / 2;
			if(hb == 1 && startx < 16) startx = 16;
			if(hb == 1 && maxx < 54) startx = maxx - 38;
			starty = 2;
			noecho();
			if(color == 1) start_color();
			init_pair(1, COLOR_CYAN, COLOR_BLACK);
			keypad(stdscr, TRUE);
			win = newwin(25, 37, starty, startx);
			helpbox = newwin(12, 15, 1, 1);
			if(color == 1) wbkgd(win, COLOR_PAIR(1));
			werase(win);
			refresh();
			wrefresh(win);
			for(i = 0;i < 10;i++)
				{
				for(j = 0;j < 10;j++)
					{
					if(i % 3 == 0) wattron(win, A_BOLD|COLOR_PAIR(2));
					if(j % 3 == 0) wattron(win, A_BOLD|COLOR_PAIR(2));
					wprintw(win, "+");
					if(j % 3 == 0 && i % 3 != 0)
						{
						wattron(win, COLOR_PAIR(1));
						wattroff(win, A_BOLD);
						}
					if(j < 9) wprintw(win, "---");
					if(i % 3 == 0)
						{
						wattron(win, COLOR_PAIR(1));
						wattroff(win, A_BOLD);
						}
					}
				for(j = 0;j < 10 && i < 9;j++)
					{
					if(j % 3 == 0) wattron(win, A_BOLD|COLOR_PAIR(2));
					if(j > 0) wprintw(win, "   |");
					else wprintw(win, "|");
					if(j % 3 == 0)
						{
						wattron(win, COLOR_PAIR(1));
						wattroff(win, A_BOLD);
						}
					}
				}
			for(i = 0;i < 9;i++)
				for(j = 0;j < 9;j++)
					if(board[i][j] != 0)
						{
						if(start[i][j] != 0)
							{
							wattron(win, A_BOLD);
							mvwprintw(win, i*2+1, j*4+2, "%d", board[i][j]);
							wattroff(win, A_BOLD);
							}
						else mvwprintw(win, i*2+1, j*4+2, "%d", board[i][j]);
						}
			if(hb == 1) helpboxon();
			else helpboxoff();
			wmove(win, 1, 2);
			wrefresh(win);
			}
		wmove(win, posy*2+1, posx*4+2);
		wrefresh(win);
		if(check() == 1 && count() == 81) ch = 900;
		}
	endwin();
	if(ch == 900) printf("Congratulations, you won the game!");
	if(print == 1) stdprint();
		
	return 0;
	}

int helpboxon(void)
	{
	wprintw(helpbox, "HelpBox\nq - quit\nr - restart\nH - HelpBox\n\nmovement:\n - arrows\n - hjkl\n\ndelete:\n - delete\n - backspace");
	wrefresh(helpbox);
	return 0;
	}

int helpboxoff(void)
	{
	werase(helpbox);
	wrefresh(helpbox);
	return 0;
	}

int change(int x, int y, int num)
	{
	board[x][y] = num;
	mvwprintw(win, y*2+1, x*3+2, "%d", num);
	wrefresh(win);
	return 0;
	}

int check(void)
	{
	int i, j, k, l, x, y;
	int c1[10], c2[10];
	for(i = 0;i < 9;i++)
		{
		for(k = 1;k < 10;k++)
			{
			c1[k] = 0;
			c2[k] = 0;
			}
		for(j = 0;j < 9;j++)
			{
			if(board[i][j] != 0) c1[board[i][j]]++;
			if(board[j][i] != 0) c2[board[j][i]]++;
			}
		for(j = 1;j < 10;j++) if(c1[j] > 1 || c2[j] > 1) return 0;
		}
	for(i = 0;i < 3;i++)
		{
		for(j = 0;j < 3;j++)
			{
			for(x = 1;x < 10;x++)
				{
				c1[x] = 0;
				c2[x] = 0;
				}
			for(k = 0;k < 3;k++)
				{
				for(l = 0;l < 3;l++)
					{
					x = (i*3)+k;
					y = (j*3)+l;
					if(board[x][y] != 0) c1[board[x][y]]++;
					if(board[y][x] != 0) c2[board[y][x]]++;
					}
				}
			for(x = 1;x < 10;x++) if(c1[x] > 1 || c2[x] > 1) return 0;
			}
		}
	return 1;
	}

int clear_grid(int i, int j)
	{
	int k, l, x, y;
	for(k = 0;k < 3;k++)
		for(l = 0;l < 3;l++)
			{
			x = (i*3)+k;
			y = (j*3)+l;
			board[x][y] = 0;
			}
	return 0;
	}

int solve_grid(int i, int j)
	{
	int k, l, x, y, z;
	for(k = 0;k < 3;k++)
		for(l = 0;l < 3;l++)
			{
			x = (i*3)+k;
			y = (j*3)+l;
			for(z = 1;z < 10;z++)
				{
				board[x][y] = z;
				if(check() == 1) z = 10;
				}
			}
	return 0;
	}

int count(void)
	{
	int i, j, ret = 0;
	for(i = 0;i < 9;i++) for(j = 0;j < 9;j++) if(board[i][j] > 0) ret++;
	return ret;
	}

int stdprint(void)
	{
	int i, j;
	for(i = 0;i < 9;i++)
		{
		printf("\n+---+---+---+---+---+---+---+---+---+\n|");
		for(j = 0;j < 9;j++)
			{
			if(board[i][j] != 0) printf(" %d |", board[i][j]);
			else printf("   |");
			}
		}
	printf("\n+---+---+---+---+---+---+---+---+---+\n");
	return 0;
	}

int generate(int n)
	{
	int i, j, k, l, r1, r2, x, y, z, num;
	for(i = 0;i < 9;i++) for(j = 0;j < 9;j++) start[i][j] = 0;
	while(check() == 0 || count() < 80)
		{
		for(i = 0;i < 3;i++) for(j = 0;j < 3;j++) clear_grid(i, j);
		for(r1 = 0, i = 0;i < 3 && r1 < 50;i++, r1++)
			{
			for(r2 = 0, j = 0;j < 3 && r2 < 100;j++, r2++)
				{
				for(k = 0;k < 3;k++)
					{
					for(l = 0;l < 3;l++)
						{
						x = (i*3)+k;
						y = (j*3)+l;
						num = (((int)rand()) % 9)+1;
						for(z = 0;z < 9;z++, num++)
							{
							if(num == 10) num = 1;
							board[x][y] = num;
							if(check() == 1) z = 10;
							}
						}
					}
				if(check() == 0)
					{
					if(i == 2 && j == 2) solve_grid(2, 2);
					else 
						{
						clear_grid(i, j);
						j--;
						}
					}
				}
			if(check() == 0)
				{
				for(j = 0;j < 3;j++) clear_grid(i, j);
				i--;
				}
			}
		}
	for(i = 0;i < n;i++)
		{
		z = 0;
		while(z == 0)
			{
			x = ((int)rand()) % 9;
			y = ((int)rand()) % 9;
			if(start[x][y] == 0)
				{
				start[x][y] = board[x][y];
				z = 1;
				}
			}
		}
	for(i = 0;i < 9;i++) for(j = 0;j < 9;j++) board[i][j] = start[i][j];
	return 0;
	}

int restart(void)
	{
	int i, j;
	for(i = 0;i < 9;i++)
		for(j = 0;j < 9;j++)
			{
			board[i][j] = start[i][j];
			if(board[i][j] != 0)
				{
				wattron(win, A_BOLD);
				mvwprintw(win, i*2+1, j*4+2, "%d", board[i][j]);
				wattroff(win, A_BOLD);
				}
			else mvwprintw(win, i*2+1, j*4+2, " ", board[i][j]);
			}
	wrefresh(win);
	return 0;
	}

void printhelp()
	{
	printf("Usage: nsudoku [OPTION...] [SOLVED]\n\n");
	printf(" SOLVED is the number of presolved cells. Default: 40\n\n");
	printf("  -c, --no-color    don't use color\n");
	printf("  -p, --no-print    don't print on exit\n");
	printf("  -h, --help give   this help list\n");
	printf("  -v, --version     print program version\n\n");
	printf("For more information visit www.tbmatuka.com/nsudoku\n");
	}

void printversion()
	{
	printf("nsudoku %s\n", VERSION);
	}
