//Dengoso 2
/*
 Comportamentos :
 move : bool
 qt_i_P : int
 qt_i_M : int
*/

import processing.serial.*;

int corMosqNor = #000000;
int corMosqInf = #BC1EAD;
int corMosqPro = #2B2FD6;
int corPersNor = #4873DE;
int corPersInf = #FF0000;
int corPersPro = #57D894;

int tempoThread = 2; //ms
int tamP = 10;
int tamM = 5;
Serial ks;
boolean run = true;

int qt_i_P = 1000;
int qt_i_M = 50;

class Person{
    String state = "normal";
    boolean recuperating = false;
    float px = 0;
    float py = 0;
    float tempoSegsRecuperate = 2.5f;
    public Person(float ipx, float ipy){
        px = ipx;
        py = ipy;
    }
    public float dist(Person p){
        return (float) Math.pow((float) (Math.pow((float)(this.px-p.px),2f) + Math.pow((float)this.py-p.py,2f)),0.5f);
    }
    public void tendency(){
        int oui = rd(1);
        float margem = 50;
        for (int i=0;i<qt_i_P;i++){
            Person p = Ps[i];
            if (this.dist(p) <= tamP){
                int tipo = rd(4)+1;
                switch (tipo){
                    case 1:
                        this.py++;
                        p.py--;
                        break;
                    case 2:
                        this.py--;
                        p.py++;
                        break;
                    case 3:
                        this.px++;
                        p.px--;
                        break;
                    case 4:
                        this.px--;
                        p.px++;
                        break;
                }
            }
        }
        if (oui == 0){
            switch (this.state){
                case "normal":
                    if (this.py < 2*height/3 + margem/2){
                        this.py++;
                    }
                    break;
                case "infec":
                    if (this.py < height/3 + margem/2){
                        this.py++;
                    }else if (this.py > 2*height/3 - margem/2){
                        this.py--;
                    }
                    break;
                case "protec":
                    if (this.py > height/3 -margem/2){
                        this.py--;
                    }
                    break;
            }
        }
    }
}

class Mosq{
    String state = "normal";
    float px = 0;
    float py = 0;
    boolean did = false;
    Person set;
    public Mosq(float ipx, float ipy){
        px = ipx;
        py = ipy;
    }
}

Person[] Ps = new Person[0];
Mosq[] Ms = new Mosq[0];

void setup(){
    size(800,800);
    create_init();
    thread("Wrunner");
}

int Rpx(){
    int px = (int) ((width+1)*random(1));
    return px;
}
int Rpy(){
    int py = (int) ((height+1)*random(1));
    return py;
}
int rd(int num){
    return (int) (random(num));
}

void keyReleased(){
    if (keyCode == DOWN){
        run = false;
    }else if (keyCode == UP){
        if (!(run)){
            run = true;
            thread("Wrunner");
        }
        run = true;
    }else if (keyCode == RIGHT){
        tempoThread += (tempoThread > 0) ? -1 : 0;
    }else if (keyCode == LEFT){
        tempoThread++;
    }
}

void create_init(){
    Ps = new Person[qt_i_P];
    Ms = new Mosq[qt_i_M];
    for (int i=0;i<qt_i_P;i++){
        Ps[i] = new Person(Rpx(),Rpy());
        if (i<10){
            Ps[i].state = "infec";
        }
        if (i==727){
            Ps[i].state = "protec";
        }
    }
    for (int i=0;i<qt_i_M;i++){
        Ms[i] = new Mosq(Rpx(),Rpy());
    }
}

void draw(){
    if (run){
        background(255,255,255);
        int qmn,qmi,qmp,qpn,qpi,qpp;
        boolean move = false;
        
        qmi=0;
        qmn=0;
        qmp=0;
        qpi=0;
        qpn=0;
        qpp=0;
        //runner();
        for (Person p : Ps){
            stroke(100000);
            if (p.state == "normal"){
                fill(corPersNor);
                qpn++;
            }else if (p.state == "protec"){
                fill(corPersPro);
                qpp++;
            }else{
                fill(corPersInf);
                qpi++;
            }

            if (move){
                p.px += rd(3)-1;
                p.py += rd(3)-1;
            }

            if (p.px < tamP/2){
                p.px += 1;
            }
            if (p.px > width-tamP/2){
                p.px -= 1;
            }
            if (p.py < tamP/2){
                p.py += 1;
            }
            if (p.py > height-tamP/2){
                p.py -= 1;
            }

            circle(p.px,p.py,tamP);
            p.tendency();
        }

        for (Mosq m : Ms){
            stroke(100000);
            if (m.state == "normal"){
                fill(corMosqNor);
                qmn++;
            }else if (m.state == "protec"){
                fill(corMosqPro);
                qmp++;
            }else{
                fill(corMosqInf);
                qmi++;
            }
            circle(m.px,m.py,tamM);
        }

        print("\n\n");
        print("\nP: " + qpn + " " + qpi + " " + qpp);
        print(" M: " + qmn + " " + qmi + " " + qmp);
        print("\n\n");
    }
}

void Wrunner(){
    while (true){
        if (run == false){
            break;
        }
        delay(tempoThread);
        runner();
    }
}

void recuperate(){
    for (Person p : Ps){
        if (p.recuperating == true){
            p.recuperating = false;
            delay((int)(p.tempoSegsRecuperate*1000));
            p.state = "protec";
            break;
        }
    }
}

void runner(){
    int num,rd;

    for (Mosq m : Ms){
        if (!(m.did)){
            num = (int) random(Ps.length);
            m.set = Ps[num];
            m.did = true;
        }else{
            rd = rd(2);
            if (rd==0){
                if (m.px > m.set.px){
                    m.px -= 1;
                }else if (m.px < m.set.px){
                    m.px += 1;
                }else if (m.py > m.set.py){
                    m.py -= 1;
                }else if (m.py < m.set.py){
                    m.py += 1;
                }
            }else{
                if (m.py > m.set.py){
                    m.py -= 1;
                }else if (m.py < m.set.py){
                    m.py += 1;
                }else if (m.px > m.set.px){
                    m.px -= 1;
                }else if (m.px < m.set.px){
                    m.px += 1;
                }
            }

            if (m.px == m.set.px && m.py == m.set.py){
                if (m.set.state == "normal"){
                    m.set.state = m.state;
                }else if (m.set.state == "infec" && m.state != "protec"){
                    m.state = m.set.state;
                }else if (m.set.state == "infec" && m.state == "protec"){
                    m.state = "infec";
                    m.set.recuperating = true;
                    thread("recuperate");
                }else if (m.set.state == "protec"){
                    m.state = "protec";
                }
                m.did = false;
            }
        }

    }
    

}