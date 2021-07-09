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
