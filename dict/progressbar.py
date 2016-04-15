# Copyright (C) 2016 Juan Martorell
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
# USA
import sys
import time


def draw_progress_bar(per_one, start, bar_len=30):
    """ Draws a "static" progress bar at the console with elapsed and estimated time
    :param per_one: Progress from 0 to 1
    :param start: Time when the activity started
    :param bar_len: length in characters for the bar itself (without trailing numbers)
    """
    sys.stdout.write("\r")
    progress = ""
    for i in range(bar_len):
        if i < int(bar_len * per_one):
            progress += "="
        else:
            progress += " "

    elapsed_time = time.time() - start
    estimated_remaining = int(elapsed_time * (1.0 / per_one) - elapsed_time)

    if per_one == 1.0:
        sys.stdout.write("[ %s ] %.1f%% Elapsed: %im %02is ETA: Done!\n" %
                         (progress, per_one * 100, int(elapsed_time) / 60, int(elapsed_time) % 60))
        sys.stdout.flush()
        return
    else:
        sys.stdout.write("[ %s ] %.1f%% Elapsed: %im %02is ETA: %im%02is " %
                         (progress, per_one * 100, int(elapsed_time) / 60, int(elapsed_time) % 60,
                          estimated_remaining / 60, estimated_remaining % 60))
        sys.stdout.flush()
        return
