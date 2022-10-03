Ansible role: Provision - OpenNebula
====================================

Provision OpenNebula virtual machine.
Provision the host as a virtual machine on an OpenNebula
cluster. The provision user is automatically created when the
VM is instantiated and the username is set to
provision_user_username and the password is set to
provision_user_password.

Provisioning virtual machines
-----------------------------

Make sure `one_frontend`, `one_api_username`, `one_api_password` are set.
For each host you also need to set `one_vm` (see example below).

Required vars (with examples):

```yaml
one_frontend: "opennebula.front.end"

one_api_username: "ansible"
one_api_password: "secret"

one_vm:
  host: "vm.host"            # Specific host to deploy VM on (optional, required for block storage)
  host_type: "production"    # Host type to deploy the VM on (optional)
  memory: "4GB"              # VM memory (required)
  cpu: 2                     # VM cpus (required)
  os: "Debian 10"            # Must match image name in OpenNebula (required)
  size: "100GB"              # Root disk size (required)
  block_storage:             # Attach logical volumes to VM (optional)
    - datastore: "DS Name"   # Must match datastore name in OpenNebula (required)
      size: "1000GB"         # Logical volume size (required)
  extra_storage:             # Extra VM disks (optional)
    - config:                # Use OpenNebula VM template variables from the disk section (required)
        type: "swap"
        dev_prefix: "vd"
      size: "4GB"            # Disk size (required)
  nics:                      # NICs to attach to the VM (required)
    - network: "Primary"     # Must match network name in OpenNebula (required)
      ip: "192.0.2.1"        # Initial NIC ipv4 address (required)
      ip6: "2001:db8::1"     # Initial NIC ipv6 address
  extra_config: ""           # String for extra OpenNebula VM template configuration (optional)
```

Requirements
------------

This role depends on the [base provision role](https://github.com/wandansible/provision).

Role Variables
--------------

```
ENTRY POINT: main - Provision OpenNebula virtual machine

        Provision the host as a virtual machine on an OpenNebula
        cluster. The provision user is automatically created when the
        VM is instantiated and the username is set to
        provision_user_username and the password is set to
        provision_user_password.

OPTIONS (= is mandatory):

= one_api_password
        Password for API authentication

        type: str

- one_api_url
        URL for the OpenNebula API (relative to the frontend server)
        [Default: http://127.0.0.1:2633/RPC2]
        type: str

- one_api_username
        Username for API authentication
        [Default: ansible]
        type: str

= one_frontend
        Hostname of the OpenNebula frontend server

        type: str

= one_vm
        Parameters used to create the virtual machine

        type: dict

        OPTIONS:

        - block_storage
            List of persistent logical volumes to attach to the VM
            [Default: (null)]
            elements: dict
            type: list

            OPTIONS:

            = datastore
                Name of an LVM datastore available for the OpenNebula
                host where the logical volume will be stored

                type: str

            = size
                Size of the logical volume, given as a number of data
                units, e.g. "1000GB"

                type: str

        = cpu
            Number of virtual CPUs

            type: int

        - datastore
            ID of the default datastore to use for the primary virtual
            disk (overrides one_vm_default_datastore)
            [Default: (null)]
            type: int

        - extra_config
            Contents for extra VM template configuration
            [Default: (null)]
            type: str

        - extra_storage
            List of extra virtual disks to attach
            [Default: (null)]
            elements: dict
            type: list

            OPTIONS:

            = config
                Configuration for the virtual disk, see https://docs.o
                pennebula.io/6.4/management_and_operations/references/
                template.html#disks-section for available options

                type: dict

            = size
                Size of the virtual disk, given as a number of data
                units, e.g. "4GB"

                type: str

        - host
            Specific host to deploy the VM on, required for block
            storage
            [Default: (null)]
            type: str

        - host_type
            Host type to deploy the VM on
            [Default: (null)]
            type: str

        = memory
            Size of the virtual memory, given as a number of data
            units, e.g. "4GB"

            type: str

        - nics
            List of virtual interfaces to attach
            [Default: (null)]
            elements: dict
            type: list

            OPTIONS:

            = ip
                IPv4 address for the host

                type: str

            = network
                Name of a virtual network available in the OpenNebula
                cluster

                type: str

        = os
            Name of an operating system image available in the
            OpenNebula cluster

            type: str

        - pinned
            If true, pin the VM to CPUs on the same NUMA node
            (overrides one_vm_pinned)
            [Default: (null)]
            type: bool

        = size
            Size of the primary virtual disk containing the root
            directory, given as a number of data units, e.g. "100GB"

            type: str

- one_vm_default_datastore
        ID of the default datastore to use for the primary virtual
        disk
        [Default: 0]
        type: int

- one_vm_pinned
        If true, pin the VM to CPUs on the same NUMA node
        [Default: False]
        type: bool

- one_vm_wait_delay
        Time, in seconds, to wait before checking for an SSH
        connection to the VM
        [Default: 10]
        type: int

- one_vm_wait_timeout
        Time, in seconds, to wait for an SSH connection to the VM
        before giving up
        [Default: 300]
        type: int
```

Installation
------------

This role can either be installed manually with the ansible-galaxy CLI tool:

    ansible-galaxy install git+https://github.com/wandansible/provision,main,wandansible.provision
    ansible-galaxy install git+https://github.com/wandansible/provision.opennebula,main,wandansible.provision.opennebula
     
Or, by adding the following to `requirements.yml`:

    - name: wandansible.provision
      src: https://github.com/wandansible/provision
    - name: wandansible.provision.opennebula
      src: https://github.com/wandansible/provision.opennebula

Roles listed in `requirements.yml` can be installed with the following ansible-galaxy command:

    ansible-galaxy install -r requirements.yml

Example Playbook
----------------

    - hosts: vms
      roles:
         - role: wandansible.provision.opennebula
           become: true
           vars:
             one_vm:
               cpu: 4
               memory: 16GB
               os: Debian 11
               size: 50GB
               nics:
                 - network: Primary
                   ip: 192.0.2.1
                   ip6: 2001:db8::1
