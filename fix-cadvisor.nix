{
  services.cadvisor = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 8080;
    extraOptions = [
      "--docker_only=true"
      "--disable_metrics=percpu,sched,tcp,udp,disk,diskIO,accelerator,hugetlb,referenced_memory,cpu_topology,resctrl"
    ];
  };
}
