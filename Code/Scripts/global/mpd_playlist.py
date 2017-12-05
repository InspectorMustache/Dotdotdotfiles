#!/bin/env python

import curses
from collections import namedtuple
from mpd import MPDClient

# $value represents what is returned when hitting enter, $str_ represents the
# menu entry as it appears to the user
MenuEntry = namedtuple('MenuEntry', ['value', 'str_'])

# $first is the number of the first entry, $last the number of the final entry
# + 1 (for use with range())
MenuPage = namedtuple('MenuPage', ['first', 'last'])

INFO_STR = 's = Replace | a = Append | Space = Play | q = Quit'


class Menu():
    """Menu class with navigation methods. Each menu entry must be an
    MenuEntry. Constructing requires a list of MenuEntry objects and a stdscr
    object from curses.wrapper."""

    def __init__(self, stdscr, entry_list, mpd_client):
        self.stdscr = stdscr
        self.entry_dict = self._get_entry_dict(entry_list)
        self.mpd_client = mpd_client

        self.current_pos = 0
        self.current_page_num = 0
        (self.base_win,
         self.sub_win,
         self.status_line) = self._init_windows(self.stdscr)
        self.pages_dict = self._get_pages_dict()

        self.draw_current_page()
        self.mark_current_position()
        self.update_screen()
        self.event_loop()

    @property
    def current_page(self):
        return self.pages_dict[self.current_page_num]

    def _init_windows(self, stdscr):
        """Draw initial interface and return objects for the base window and
        the window which actually contains all menu entries (sub_win)."""
        stdscr.clear()
        curses.curs_set(0)

        base_win = curses.newwin(curses.LINES - 4,
                                 curses.COLS - 2,
                                 1, 1)
        base_win.box()

        status_line = curses.newwin(1, curses.COLS, curses.LINES - 2, 0)
        _, status_line_width = status_line.getmaxyx()
        formatted_msg = self.center_text(INFO_STR, status_line_width)
        status_line.addstr(0, 0, formatted_msg)
        status_line.chgat(0, 0, curses.A_REVERSE)

        base_win_height, base_win_width = base_win.getmaxyx()
        sub_win = base_win.derwin(base_win_height - 2,
                                  base_win_width - 2,
                                  1, 1)

        # make windows available to all methods

        return (base_win, sub_win, status_line)

    def draw_current_page(self):
        """Draw currently active page."""
        for pos in range(self.current_page.first, self.current_page.last):
            pos_on_page = pos - self.current_page.first
            entry = self.entry_dict[pos]
            self.sub_win.addstr(pos_on_page, 0, entry.str_)

    def _get_entry_dict(self, entry_list):
        positions = len(entry_list)
        entry_dict = {pos: entry_list[pos] for pos in range(positions)}
        return entry_dict

    def _get_pages_dict(self):
        """Return a dictionary of pages and their containing entries by
        position reference."""
        entry_count = len(self.entry_dict)
        page_size, _ = self.sub_win.getmaxyx()
        # page_breaks = those positions at which a page ends and a new one
        # begins
        page_breaks = list(range(entry_count))[::page_size]

        pages_dict = {}
        for iter_, page in enumerate(page_breaks):
            first_page = page_breaks[iter_]
            try:
                last_page = page_breaks[iter_ + 1]
            except IndexError:
                last_page = entry_count

            pages_dict[iter_] = MenuPage(first=first_page, last=last_page)

        return pages_dict

    def center_text(self, msg, line_width):
        """Return a padded string so that $msg appears centered."""
        # apparently you can't print to the final column?
        line_width -= 1

        padding = int((line_width - len(msg)) / 2)
        if len(msg) > line_width:
            formatted_msg = '{}…'.format(msg[:line_width - 1])
        else:
            formatted_msg = '{0}{1}{0}'.format(' ' * padding, msg)

        return formatted_msg

    def print_to_status_line(self, msg):
        """Print $msg to the status line."""
        formatted_msg = self.center_text(str(msg), curses.COLS)

        self.status_line.addstr(0, 0, formatted_msg)
        self.status_line.chgat(0, 0, curses.A_REVERSE)

    def mark_current_position(self):
        """Mark line at position $pos."""
        relative_pos = self.current_pos - self.current_page.first
        y_pos, x_pos = self.sub_win.getyx()
        self.sub_win.move(relative_pos, 0)
        self.sub_win.chgat(curses.A_REVERSE)
        # reset cursor position
        self.sub_win.move(y_pos, x_pos)

    def move_selection(self, steps):
        """Move selection $steps forwards or backwards."""
        self.sub_win.clear()
        new_pos = self.current_pos + steps

        # move specified step closer to zero until the new position is within
        # bounds
        while new_pos > len(self.entry_dict) - 1 or new_pos < 0:
            if new_pos > 0:
                new_pos -= 1
            elif new_pos < 0:
                new_pos += 1

        if 0:
            # if after adjusting the step there's nothing left, don't move
            # selection
            return
        if new_pos in range(self.current_page.first,
                            self.current_page.last):
            # if new position is still on the same page, move selection to the
            # new position
            self.current_pos = new_pos
            self.draw_current_page()
            self.mark_current_position()
        else:
            # if new position is on a different page, find that page, draw it
            # and move selection to the new position
            for page_num, page in self.pages_dict.items():
                if new_pos in range(page.first, page.last):
                    self.current_pos = new_pos
                    self.current_page_num = page_num
                    break

            self.draw_current_page()
            self.mark_current_position()

        self.update_screen()

    def update_screen(self):
        """Refresh all windows and redraw screen."""
        self.stdscr.noutrefresh()
        self.base_win.noutrefresh()
        self.sub_win.noutrefresh()
        self.status_line.noutrefresh()
        curses.doupdate()

    def event_loop(self):
        """Wait for input and process it."""
        play_pos = 0

        while True:
            key_input = self.stdscr.getch()

            if key_input == ord('j') or key_input == curses.KEY_DOWN:
                self.move_selection(1)
            elif key_input == ord('k') or key_input == curses.KEY_UP:
                self.move_selection(-1)
            elif key_input == ord('d'):
                self.move_selection(5)
            elif key_input == ord('u'):
                self.move_selection(-5)
            elif key_input == ord('s'):
                self.mpd_client.clear()
                self.mpd_client.load(self.entry_dict[self.current_pos].value)
            elif key_input == ord('a'):
                play_pos = len(self.mpd_client.playlist())
                self.mpd_client.load(self.entry_dict[self.current_pos].value)
            elif key_input == ord(' '):
                self.mpd_client.play(play_pos)
            elif key_input == ord('q'):
                break


def get_mpd_client(host, port):
    mpd_client = MPDClient()
    mpd_client.connect(host, port)
    return mpd_client


def playlist_to_entry(playlist_item):
    return MenuEntry(value=playlist_item['playlist'],
                     str_=playlist_item['playlist'])


mpd_c = get_mpd_client("localhost", 6600)
entries = list(map(playlist_to_entry, mpd_c.listplaylists()))
curses.wrapper(Menu, entries, mpd_c)
