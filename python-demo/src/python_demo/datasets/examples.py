"""Examples.py: modules that create datasets.

Simple module that generates the datasets we need for the Python versions
of the public network analysis demos.
"""
import pandas as pd
from pandas import DataFrame


def clique_graph_from_links() -> DataFrame:
    """clique_graph_from_links :: Generates a dataset we use in the clique example.

    Returns:
        DataFrame: The edge list we provide.
    """
    colNames = ["from", "to"]
    links = [
        (0, 1),
        (0, 2),
        (0, 3),
        (0, 4),
        (0, 5),
        (0, 6),
        (1, 2),
        (1, 3),
        (1, 4),
        (2, 3),
        (2, 4),
        (2, 5),
        (2, 6),
        (2, 7),
        (2, 8),
        (3, 4),
        (5, 6),
        (7, 8),
        (8, 9),
    ]

    df = pd.DataFrame(links, columns=colNames)
    return df


def community_graph_links() -> DataFrame:
    """community_graph_links :: Generate the edges (links) used in a simple community detection example.

    Returns:
        DataFrame: Created from the provided edge list
    """
    colNames = ["from", "to"]
    links = [
        ("A", "B"),
        ("A", "F"),
        ("A", "G"),
        ("B", "C"),
        ("B", "D"),
        ("B", "E"),
        ("C", "D"),
        ("E", "F"),
        ("G", "I"),
        ("G", "H"),
        ("H", "I"),
    ]

    df = pd.DataFrame(links, columns=colNames)
    return df


def community_graph_nodes() -> DataFrame:
    """community_graph_nodes :: nodes with their fixed pairs for each community.

    Returns:
        DataFrame: Created from the provided node list.
    """
    colNames = ["node", "fixGroup"]
    nodes = [("A", 1), ("B", 1), ("C", 2), ("D", 2), ("H", 3), ("I", 3)]

    df = pd.DataFrame(nodes, columns=colNames)
    return df


def paths_graph_from_links() -> DataFrame:
    """paths_graph_from_links :: return a directed graph with weighted edges.

    Returns:
        DataFrame: created from edge / weight list.
    """
    colNames = ["from", "to", "weight"]
    links = [
        ("A", "B", 1),
        ("A", "E", 1),
        ("B", "C", 1),
        ("C", "A", 6),
        ("C", "D", 1),
        ("D", "E", 3),
        ("D", "F", 1),
        ("E", "B", 1),
        ("E", "C", 4),
        ("F", "E", 1),
        ("E", "A", 1),
    ]

    df = pd.DataFrame(links, columns=colNames)
    return df
