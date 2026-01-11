# Kubernetes fzf-tab Previews - Enhanced with your requested features

zstyle ':fzf-tab:complete:kubectl:*' fzf-preview '
case ${words[2]} in
  logs)
    echo "Last 75 lines: $word"
    kubectl logs $word --tail=75 2>/dev/null || echo "No logs"
    echo ""
    echo "Full: kubectl logs $word"
    ;;
  describe)
    kubectl describe ${words[3]:-pod} $word 2>/dev/null | head -100
    ;;
  get)
    case ${words[3]} in
      pod|pods|po)
        kubectl get pod $word -o wide 2>/dev/null
        ;;
      svc|service|services)
        kubectl get svc $word -o wide 2>/dev/null
        ;;
      deployment|deployments|deploy)
        kubectl get deployment $word -o wide 2>/dev/null
        ;;
      
      # SECRETS - Show keys with masked values
      secret|secrets)
        echo "Secret: $word"
        kubectl get secret $word -o go-template="Type: {{.type}}{{println}}{{println}}Keys:" 2>/dev/null
        kubectl get secret $word -o go-template="{{range \$k, \$v := .data}}  {{println}}- {{print \$k}}: {{printf \"%.20s\" \$v}}***{{end}}" 2>/dev/null
        ;;
      
      configmap|configmaps|cm)
        kubectl get configmap $word -o yaml 2>/dev/null | head -30
        ;;
      
      node|nodes|no)
        kubectl get node $word -o wide 2>/dev/null
        ;;
      
      # PERSISTENT VOLUMES
      pv|persistentvolume|persistentvolumes)
        echo "PersistentVolume: $word"
        kubectl get pv $word -o wide 2>/dev/null
        kubectl get pv $word -o go-template="{{println}}Capacity: {{.spec.capacity.storage}}{{println}}Class: {{.spec.storageClassName}}{{println}}Status: {{.status.phase}}" 2>/dev/null
        ;;
      
      # PERSISTENT VOLUME CLAIMS
      pvc|persistentvolumeclaim|persistentvolumeclaims)
        echo "PVC: $word"
        kubectl get pvc $word -o wide 2>/dev/null
        kubectl get pvc $word -o go-template="{{println}}Requested: {{.spec.resources.requests.storage}}{{println}}Class: {{.spec.storageClassName}}{{println}}Status: {{.status.phase}}" 2>/dev/null
        ;;
      
      # SERVICE ACCOUNTS
      serviceaccount|serviceaccounts|sa)
        echo "ServiceAccount: $word"
        kubectl get serviceaccount $word -o yaml 2>/dev/null | head -25
        ;;
      
      # ROLES
      role|roles)
        echo "Role: $word"
        kubectl get role $word -o yaml 2>/dev/null | head -30
        ;;
      
      # ROLEBINDINGS
      rolebinding|rolebindings|rb)
        echo "RoleBinding: $word"
        kubectl get rolebinding $word -o yaml 2>/dev/null | head -30
        ;;
      
      # CUSTOM RESOURCE DEFINITIONS
      crd|customresourcedefinition|customresourcedefinitions)
        echo "CRD: $word"
        kubectl get crd $word -o wide 2>/dev/null
        kubectl get crd $word -o go-template="{{println}}Group: {{.spec.group}}{{println}}Scope: {{.spec.scope}}" 2>/dev/null
        ;;
      
      # EVENTS
      event|events|ev)
        echo "Recent Events (last 20):"
        kubectl get events --sort-by=.lastTimestamp 2>/dev/null | tail -20
        ;;
      
      # KARPENTER - NodePool
      nodepool|nodepools)
        echo "Karpenter NodePool: $word"
        kubectl get nodepool $word -o yaml 2>/dev/null | head -50
        ;;
      
      # KARPENTER - NodeClass
      nodeclass|nodeclasses|ec2nodeclass)
        echo "Karpenter NodeClass: $word"
        kubectl get ec2nodeclass $word -o yaml 2>/dev/null | head -50
        ;;
      
      # KARPENTER - Machine (deprecated, now NodeClaim)
      machine|machines|nodeclaim|nodeclaims)
        echo "Karpenter NodeClaim: $word"
        kubectl get nodeclaim $word -o wide 2>/dev/null || kubectl get machine $word -o wide 2>/dev/null
        ;;
      
      *)
        kubectl get $word -o wide 2>/dev/null
        ;;
    esac
    ;;
  delete)
    echo "DELETE WARNING: $word"
    kubectl get ${words[3]} $word 2>/dev/null
    echo ""
    echo "This CANNOT be undone!"
    ;;
  *)
    echo "kubectl ${words[2]}: $word"
    ;;
esac
'
