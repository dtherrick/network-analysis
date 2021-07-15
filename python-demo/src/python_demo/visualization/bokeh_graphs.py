"""bokeh_graphs.py :: A helper module to create network plots."""

from typing import Any, List


from bokeh.core.enums import Palette
from bokeh.io import save
from bokeh.models import Circle, MultiLine, Range1d
from bokeh.models.annotations import LabelSet
from bokeh.models.graphs import NodesAndLinkedEdges
from bokeh.models.plots import Plot
from bokeh.models.sources import ColumnDataSource
from bokeh.models.tools import HoverTool
from bokeh.palettes import Blues8
from bokeh.plotting import from_networkx
import networkx as nx
from networkx import Graph

NX_SPRING_SEED = 96201546


def set_node_colors(
    graph: Graph, attr_to_highlight: Any, ref_attr: str, color_palette: Palette
) -> None:
    """set_node_colors: set colors based on binary settings.

    Args:
        graph (Graph): The input graph.
        attr_to_highlight (Any): Value of the attribute to highlight.
        ref_attr (str): label of the attribute.
        color_palette (Palette): Bokeh palette to use.
    """
    for node in graph.nodes():
        graph.nodes[node]["highlight"] = color_palette[graph.nodes[node]["clique"]]


def render_plot(
    graph: Graph,
    title: str,
    hover_tooltips: List,
    node_size: int = 15,
    node_color: str = Blues8[-1],
    node_alpha: float = 1.0,
    outfile: str = None,
) -> Plot:
    """render_plot :: simple function to plot a graph using bokeh.

    Args:
        graph (Graph): The input, fully prepared graph.
        title (str): Title of the graph we're creating.
        hover_tooltips (List): the list of tuples that should display on hover.
        node_size (int): Optional, default 15. Set the size of the nodes.
        node_color (str): Optional. attribute label with each node's color.
        node_alpha (float): Optional. Background color transparency.
        outfile (str): Optional. Name of the export file. Defaults to None.

    Returns:
        Plot: The prepared Bokeh figure ready for display.
    """
    # Create a plot — set dimensions, toolbar, and title
    plot = Plot(
        x_range=Range1d(-10.1, 10.1),
        title=title,
    )

    plot.xgrid.grid_line_color = None
    plot.ygrid.grid_line_color = None

    # Create a network graph object with spring layout
    nw_graph = from_networkx(
        graph, nx.spring_layout, scale=10, center=(2, 0), seed=NX_SPRING_SEED
    )

    # Set node size and color
    nw_graph.node_renderer.glyph = Circle(
        size=node_size, fill_color=node_color, fill_alpha=node_alpha
    )

    # Set edge opacity and width
    nw_graph.edge_renderer.glyph = MultiLine(line_alpha=0.5, line_width=2)

    # green hover for both nodes and edges
    nw_graph.node_renderer.hover_glyph = Circle(size=node_size, fill_color="#abdda4")
    nw_graph.edge_renderer.hover_glyph = MultiLine(line_color="#abdda4", line_width=4)

    nw_graph.inspection_policy = NodesAndLinkedEdges()

    plot.add_tools(HoverTool(tooltips=hover_tooltips))

    # Add network graph to the plot
    plot.renderers.append(nw_graph)

    # Add Labels
    x, y = zip(*nw_graph.layout_provider.graph_layout.values())
    node_labels = list(graph.nodes())
    source = ColumnDataSource(
        {"x": x, "y": y, "name": [node_labels[i] for i in range(len(x))]}
    )
    labels = LabelSet(
        x="x",
        x_offset=-5,
        y="y",
        y_offset=-5,
        text="name",
        source=source,
        background_fill_color=node_color,
        text_font_size="13px",
        background_fill_alpha=node_alpha,
    )
    plot.renderers.append(labels)

    if outfile is not None:
        save(plot, filename=outfile)

    return plot
