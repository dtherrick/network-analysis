"""Examples.py: modules that create datasets.

Simple module that generates the datasets we need for the Python versions
of the public network analysis demos.
"""
from typing import Dict

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


def community_karate_club_links() -> DataFrame:
    """community_karate_club_links :: Load the Zachary's Karate Club network.

    Returns:
        DataFrame: an edgelist dataframe.
    """
    colNames = ["from", "to"]
    links = [
        (0, 9),
        (0, 10),
        (0, 14),
        (0, 15),
        (0, 16),
        (0, 19),
        (0, 20),
        (0, 21),
        (0, 33),
        (2, 1),
        (3, 1),
        (3, 2),
        (4, 1),
        (4, 2),
        (4, 3),
        (5, 1),
        (0, 23),
        (0, 24),
        (0, 27),
        (0, 28),
        (0, 29),
        (0, 30),
        (0, 31),
        (0, 32),
        (6, 1),
        (7, 1),
        (7, 5),
        (7, 6),
        (8, 1),
        (8, 2),
        (8, 3),
        (8, 4),
        (9, 1),
        (9, 3),
        (10, 3),
        (11, 1),
        (11, 5),
        (11, 6),
        (12, 1),
        (13, 1),
        (13, 4),
        (14, 1),
        (14, 2),
        (14, 3),
        (14, 4),
        (17, 6),
        (17, 7),
        (18, 1),
        (18, 2),
        (20, 1),
        (20, 2),
        (22, 1),
        (22, 2),
        (26, 24),
        (26, 25),
        (28, 3),
        (28, 24),
        (28, 25),
        (29, 3),
        (30, 24),
        (30, 27),
        (31, 2),
        (31, 9),
        (32, 1),
        (32, 25),
        (32, 26),
        (32, 29),
        (33, 3),
        (33, 9),
        (33, 15),
        (33, 16),
        (33, 19),
        (33, 21),
        (33, 23),
        (33, 24),
        (33, 30),
        (33, 31),
        (33, 32),
    ]
    df = pd.DataFrame(links, columns=colNames)
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


def reach_graph_from_links() -> DataFrame:
    """reach_graph_from_links :: return a graph representing an org structure.

    Returns:
        DataFrame: created from edge list
    """
    colNames = ["employee_id", "manager_id"]
    links = [
        (1, 0),
        (2, 1),
        (3, 1),
        (4, 1),
        (5, 1),
        (6, 2),
        (7, 2),
        (8, 2),
        (9, 2),
        (10, 3),
        (11, 3),
        (12, 3),
        (13, 3),
        (14, 4),
        (15, 4),
        (16, 7),
        (17, 7),
        (18, 8),
        (19, 8),
        (20, 8),
    ]
    df = pd.DataFrame(links, columns=colNames)
    return df


def reach_nodes() -> Dict:
    """reach_nodes :: provide the node attribute information.

    Returns:
        Dict: key is node id, value is employee name.
    """
    nodes = {
        {1: "Michael North"},
        {2: "Megan Berry"},
        {3: "Sarah Berry"},
        {4: "Zoe Black"},
        {5: "Tim James"},
        {6: "Bella Tucker"},
        {7: "Ryan Metcalfe"},
        {8: "Max Mills"},
        {9: "Benjamin Glover"},
        {10: "Carolyn Henderson"},
        {11: "Nicola Kelly"},
        {12: "Alexandra Climo"},
        {13: "Dominic King"},
        {14: "Leonard Gray"},
        {15: "Eric Rampling"},
        {16: "Piers Paige"},
        {17: "Ryan Henderson"},
        {18: "Frank Tucker"},
        {19: "Nathan Ferguson"},
        {20: "Kevin Rampling"},
    }
    return nodes
