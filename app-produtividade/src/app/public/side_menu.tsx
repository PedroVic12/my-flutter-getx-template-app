import React from 'react';
import {
  IonContent,
  IonMenu,
  IonList,
  IonItem,
  IonIcon,
  IonLabel,
  IonHeader,
  IonMenuToggle,
  IonTitle,
  IonToolbar,
} from '@ionic/react';



import { appRoutes } from '../../App';

const SidebarMenu: React.FC = () => {

  return (
    <IonMenu contentId="main" type="overlay">
      <IonHeader>
        <IonToolbar>
          <IonTitle>Menu Lateral</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent>
        <IonList>
          {appRoutes.map((item, index) => (
            <IonMenuToggle key={index} autoHide={false}>
              <IonItem routerLink={item.path} routerDirection="forward" lines="none">
                <IonIcon slot="start" icon={item.icon} />
                <IonLabel>{item.label}</IonLabel>
              </IonItem>
            </IonMenuToggle>
          ))}
        </IonList>
      </IonContent>
    </IonMenu>
  );
};

export default SidebarMenu;
