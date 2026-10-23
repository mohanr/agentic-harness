open Containers

module  Node_processing_order = CCVector
module  Neighboring_clusters= CCVector
module  Neighboring_cluster_edge_weights= CCVector
module  Singleton_clusters= CCVector
module  Summed_qvi_records= CCVector

type sub_networkclustering_generator = {
    node_processing_order: int Node_processing_order.vector;
    neighboring_clusters: int Neighboring_clusters.vector;
    neighboring_cluster_edge_weights : int Neighboring_cluster_edge_weights.vector;
    singleton_clusters: int Singleton_clusters.vector;
    summed_qvi_records: int Summed_qvi_records.vector
  }
