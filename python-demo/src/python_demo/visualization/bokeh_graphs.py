"""bokeh_graphs.py :: A helper module to create network plots."""

from typing import List

from bokeh.io import save
from bokeh.models import Circle, MultiLine, Range1d
from bokeh.plotting import figure, from_networkx

import networkx as nx
from networkx import Graph


def plot_cliques(
    graph: Graph,
    title: str,
    hover_tooltips: List,
    color_attr: str = "skyblue",
    outfile: str = None,
) -> figure:
    """plot_cliques :: simple function to plot a graph using bokeh.

    Args:
        graph (Graph): The input, fully prepared graph.
        title (str): Title of the graph we're creating.
        hover_tooltips (List): the list of tuples that should display on hover.
        color_attr (str): Optional. attribute label with each node's color.
        outfile (str): Optional. Name of the export file. Defaults to None.

    Returns:
        figure: The prepared Bokeh figure ready for display.
    """
    # Create a plot — set dimensions, toolbar, and title
    plot = figure(
        tooltips=hover_tooltips,
        tools="pan,wheel_zoom,save,reset",
        active_scroll="wheel_zoom",
        x_range=Range1d(-10.1, 10.1),
        y_range=Range1d(-10.1, 10.1),
        title=title,
    )

    plot.xgrid.grid_line_color = None
    plot.ygrid.grid_line_color = None

    # Create a network graph object with spring layout
    # https://networkx.github.io/documentation/networkx-1.9/reference/generated/networkx.drawing.layout.spring_layout.html
    nw_graph = from_networkx(graph, nx.spring_layout, scale=9, center=(0, 0))

    # Set node size and color
    nw_graph.node_renderer.glyph = Circle(size=15, fill_color=color_attr)

    # Set edge opacity and width
    nw_graph.edge_renderer.glyph = MultiLine(line_alpha=0.5, line_width=1)

    # Add network graph to the plot
    plot.renderers.append(nw_graph)

    if outfile is not None:
        save(plot, filename=outfile)

    return plot
