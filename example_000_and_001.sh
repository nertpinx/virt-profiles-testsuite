#!/bin/bash

nc -l -p ${PORT-12345} <<EOF
HTTP/1.1 200 OK
Content-type: application/json
Content-Length: 97

[
  "add-qxl",
  "hyperv-defaults",
  "myapp-defaults",
  "sensible-defaults",
  "spice-stuff"
]
EOF

nc -l -p ${PORT-12345} <<EOF
HTTP/1.1 200 OK
Content-type: application/json
Content-Length: 3871

[
  {
    "add-qxl": {
      "version": "v1alpha1",
      "metadata": {
        "name": "add-qxl"
      },
      "spec": {
        "domainspec": [
          {
            "action": "add",
            "data": {
              "devices": {
                "video": {
                  "model": {
                    "@type": "qxl"
                  }
                }
              }
            }
          }
        ]
      }
    }
  },
  {
    "hyperv-defaults": {
      "version": "v1alpha1",
      "metadata": {
        "name": "hyperv-defaults"
      },
      "spec": {
        "domainspec": [
          {
            "action": "add",
            "data": {
              "features": {
                "hyperv": {
                  "relaxed": {
                    "@state": true
                  },
                  "vapic": {
                    "@state": true
                  },
                  "spinlocks": {
                    "@state": true,
                    "@retries": 8191
                  }
                }
              }
            }
          }
        ]
      }
    }
  },
  {
    "myapp-defaults": {
      "version": "v1alpha1",
      "metadata": {
        "name": "myapp-defaults"
      },
      "spec": {
        "domainspec": [
          {
            "action": "defaults",
            "type": "hard",
            "data": {
              "devices": [
                {
                  "graphics": {
                    "@type": "spice"
                  }
                },
                {
                  "interface": {
                    "model": {
                      "@type": "e1000e"
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  },
  {
    "sensible-defaults": {
      "version": "v1alpha1",
      "metadata": {
        "name": "sensible-defaults"
      },
      "spec": {
        "vmspec": [
          {
            "action": "default",
            "data": {
              "devices": {
                "interfaces": [
                  {
                    "model": null,
                    "@type": "virtio"
                  }
                ]
              }
            }
          }
        ],
        "domainspec": [
          {
            "action": "add",
            "multiple": false,
            "data": {
              "devices": [
                {
                  "video": {
                    "model": {
                      "@type": "qxl"
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  },
  {
    "spice-stuff": {
      "version": "v1alpha1",
      "metadata": {
        "name": "spice-stuff"
      },
      "spec": {
        "match": [
          {
            "domainspec": {
              "devices": [
                {
                  "graphics": {
                    "@type": "spice"
                  }
                }
              ]
            }
          }
        ],
        "domainspec": [
          {
            "action": "add",
            "data": {
              "devices": [
                {
                  "video": {
                    "model": {
                      "@type": "qxl"
                    }
                  }
                }
              ]
            }
          },
          {
            "action": "add",
            "multiple": true,
            "data": {
              "devices": [
                {
                  "redirdev": {
                    "@bus": "usb",
                    "@type": "spicevmc"
                  }
                },
                {
                  "redirdev": {
                    "@bus": "usb",
                    "@type": "spicevmc"
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
]
EOF
