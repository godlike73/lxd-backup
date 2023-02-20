#!/bin/bash

# define backup destination
BACKUP_DIR=/storage/Backup/LXC/

# list all running and stopped LXC containers
LXC_CONTAINERS=$(lxc list --format csv --columns n | awk -F',' '{print $1}')

# print a menu of available containers to select from
echo "Select the containers to backup:"

PS3='Enter a number: '
select container in $LXC_CONTAINERS "Backup all containers" "Quit"; do
    case $container in
        "Backup all containers")
            # backup all containers
            for c in $LXC_CONTAINERS; do
                BACKUP_FILE=$BACKUP_DIR/$c-$(date +%Y%m%d).tar.gz
                if [ -e "$BACKUP_FILE" ]; then
                    read -p "File $BACKUP_FILE already exists. Overwrite? [y/n] " -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        if lxc export $c $BACKUP_FILE; then
                            echo "Container $c has been backed up to $BACKUP_DIR"
                        else
                            echo "Failed to back up container $c"
                        fi
                    else
                        echo "Skipping container $c"
                    fi
                else
                    if lxc export $c $BACKUP_FILE; then
                        echo "Container $c has been backed up to $BACKUP_DIR"
                    else
                        echo "Failed to back up container $c"
                    fi
                    
                                    fi
            done
            echo "All containers have been backed up to $BACKUP_DIR"
            break
            ;;
        "Quit")
            break
            ;;
        *)
            # backup selected container
            valid_selection=0
            for c in $LXC_CONTAINERS; do
                if [ "$container" == "$c" ]; then
                    valid_selection=1
                    break
                fi
            done

            if [ $valid_selection -eq 1 ]; then
                BACKUP_FILE=$BACKUP_DIR/$container-$(date +%Y%m%d).tar.gz
                if [ -e "$BACKUP_FILE" ]; then
                    read -p "File $BACKUP_FILE already exists. Overwrite? [y/n] " -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        if lxc export $container $BACKUP_FILE; then
                            echo "$container has been backed up to $BACKUP_DIR"
                        else
                            echo "Failed to back up $container"
                        fi
                    else
                        echo "Skipping container $container"
                    fi
                else
                    if lxc export $container $BACKUP_FILE; then
                        echo "$container has been backed up to $BACKUP_DIR"
                                            else
                        echo "Failed to back up $container"
                    fi
                fi
            else
                echo "Invalid selection"
            fi
            ;;
    esac
done
