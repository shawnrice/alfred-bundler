#!/usr/bin/python
# encoding: utf-8
#
# Copyright © 2014 deanishe@deanishe.net
#
# MIT Licence. See http://opensource.org/licenses/MIT
#
# Created on 2014-08-10
#

"""flipped_demo.py > output.html

Generate an HTML preview of flipped icons. HTML is written to STDOUT.
"""

from __future__ import print_function, unicode_literals

import sys
import random

from pybundler import AlfredBundler as bundler

# Set seed to always use the same colours
random.seed('dave')

ICON_COUNT = 100
DEMO_FONT = 'fontawesome'
DEMO_ICON = 'apple'
BG_DARK = '444'
BG_LIGHT = 'eee'

TEMPLATE="""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Colour flipping demo</title>
    <style type="text/css">
        html>body {
            margin: 0;
            padding: 10px;
            background: #fff;
            font-family: "Helvetica Neue", Arial, sans-serif;
            font-size: 14px;
        }
        div#content {
            width: 512px;
        }
        div#toggleBox {
            padding-top: 12px;
            float: right;
        }
        p.colour {
            text-align: center;
        }
        td.dark p.colour {
            color: #%(textlight)s;
        }
        td.light p.colour {
            color: #%(textdark)s;
        }
        td.dark {
            background: #%(bgdark)s;
        }
        td.light {
            background: #%(bglight)s;
        }
        table {
            border-collapse: collapse;
        }
        th, td {
            padding: 5px 8px;
            border-right: 3px solid #fff;
            text-align: center;
        }
        th {
            font-weight: bold;
            backround-color: #ddd;
            border-bottom: 2px solid #ccc;
        }
        td {
            border-bottom: 2px solid #fff;
        }
    </style>
</head>
<body>
    <div id="content">
        <div id="toggleBox">
            <input type="checkbox" name="toggle" id="toggle">
            <label for="toggle">Hide correct results</label>
        </div>
        <h1>Colour flipping demo</h1>
        <table>
            <thead>
                <tr>
                    <th>Flip 1</th>
                    <th>&laquo; Start &raquo;</th>
                    <th>Flip 2</th>
                    <th>Flips same?</th>
                </tr>
            </thead>
            <tbody>
    %(content)s
            </tbody>
        </table>
    </div>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
    <script type="text/javascript">
    $("#toggle").bind("click", function(event) {
        $("tr.correct").toggle();
    });
    </script>
</body>
</html>
"""


def main():

    if len(sys.argv) > 1:
        if sys.argv[1] in ('-h', '--help'):
            print(__doc__, file=sys.stderr)
            return

    lines = []

    def _make_cell(color, font=DEMO_FONT, icon=DEMO_ICON, status=False):
        class_ = ('dark', 'light')[bundler.color_is_dark(color)]
        if status:
            width = '32'
        else:
            width = '128'
        icon = bundler.icon(font, icon, color)

        buffer = ['\t<td class="{}">'.format(class_)]
        buffer.append('\t\t<img width="{}" src="{}"/>'.format(width, icon))
        if not status:
            buffer.append('\t\t<p class="colour">#{}</p>'.format(color))
        buffer.append('\t</td>')

        return '\n'.join(buffer)

    for i in range(ICON_COUNT):
        r = random.randint(0, 255)
        g = random.randint(0, 255)
        b = random.randint(0, 255)

        css1 = '{:02x}{:02x}{:02x}'.format(r, g, b)
        css2 = bundler.flip_color(css1)
        css3 = bundler.flip_color(css2)

        if css1 == css3:
            correct = True
        else:
            correct = False

        if correct:
            lines.append('<tr class="correct">')
        else:
            lines.append('<tr class="incorrect">')

        lines.append(_make_cell(css2))
        lines.append(_make_cell(css1))
        lines.append(_make_cell(css3))

        if correct:
            lines.append(_make_cell('2cd012', 'fontawesome',
                                    'thumbs-up', True))
        else:
            lines.append(_make_cell('f22538', 'fontawesome',
                                    'thumbs-down', True))

        lines.append('</tr>')

    content = '\n\t\t\t'.join(lines)

    print(TEMPLATE % dict(content=content,
                          bgdark=BG_DARK,
                          bglight=BG_LIGHT,
                          textlight=bundler.flip_color(BG_DARK),
                          textdark=bundler.flip_color(BG_LIGHT)))


if __name__ == '__main__':
    main()
